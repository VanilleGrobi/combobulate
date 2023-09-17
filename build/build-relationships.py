#!/usr/bin/env python

import requests
from pathlib import Path
import itertools
import argparse


from collections import defaultdict
import json
import logging
from dataclasses import dataclass
from pprint import pprint as pp
from typing import List
import configparser

logging.basicConfig()
log = logging.getLogger(__name__)
log.setLevel(logging.INFO)



DEFAULT_FIELD_NAME = "*unnamed*"


def lisp_string(s):
    return '"%s"' % s


class Symbol(str):
    pass


class Quote(list):
    pass


class LispString(str):
    pass


def sexp(args):
    match args:
        case dict() as a:
            plist = []
            for k, v in a.items():
                plist.extend([Symbol(":" + k), v])
            return sexp(plist)
        case Quote() as a:
            return "'" + "".join(a)
        case LispString() as a if a:
            return lisp_string(a)
        case (Symbol() | str()) as a:
            return a
        case (set() | list()) as arg if arg:
            return Symbol("(") + " ".join(sexp(a) for a in arg if a) + Symbol(")")
        case None:
            return Symbol("nil")


def match_rule(obj, rules):
    def handle_types(types):
        children = set()
        for child_type in types:
            match child_type:
                case {"named": True, "type": child_type}:
                    if child_type.startswith("_"):
                        children |= rules[child_type][DEFAULT_FIELD_NAME]
                    else:
                        children.add(LispString(child_type))
        return children

    match obj:
        case {"type": t, "named": True, "subtypes": st}:
            t = LispString(t)
            rules[t][DEFAULT_FIELD_NAME] |= handle_types(st)
        # Canonical case
        case {
            "fields": fields,
            "named": True,
            "type": t,
            **rest,
        }:
            t = LispString(t)
            try:
                types = rest["children"]["types"]
                rules[t][DEFAULT_FIELD_NAME] |= handle_types(types)
            except KeyError:
                pass
            for field_name, details in fields.items():
                rules[t][field_name] |= handle_types(details["types"])


def build_inverse_rules(rules):
    d = defaultdict(set)
    for rule, per_field_rules in rules.items():
        for field, sub_rules in per_field_rules.items():
            for sub_rule in sub_rules:
                d[sub_rule].add(rule)
    return d


def process_rules(data):
    results = []
    subtypes = {}
    rules = defaultdict(lambda: defaultdict(set))
    for obj in data:
        result = match_rule(obj, rules)
    inv_rules = build_inverse_rules(rules)
    return rules, inv_rules


def generate_sexp(rules, inv_rules, language, source):
    l = []
    for rule_name, rule_fields in rules.items():
        # Ignore named fields and only generate the defaults?
        # without named fields.
        for field_name, field_values in rule_fields.items():
            if not field_values:
                rule_fields[field_name] = Symbol("nil")
        rules = itertools.chain.from_iterable(rule_fields.values())
        l.append(sexp([rule_name, rule_fields]))
        l.append("\n")
    return [
        sexp(
            [
                Symbol("defconst"),
                Symbol(f"combobulate-rules-{language}"),
                "\n",
                Quote(sexp(sexp(l))),
            ]
        ),
        sexp(
            [
                Symbol("defconst"),
                Symbol(f"combobulate-rules-{language}-inverted"),
                "\n",
                Quote(sexp([sexp([k, v]) + "\n  " for k, v in inv_rules.items()])),
                "\n",
            ]
        ),
    ]


def load_node_types(source):
    assert isinstance(source, Path), f"{source} must be a Path-like object."
    try:
        return json.loads(source.read_text())
    except Exception:
        log.critical(
            "Cannot find source %s. Try downloading the sources first with `--download'.",
            source,
        )
        raise


def download_source(source, output_filename, url):
    log.info("Downloading source %s. Output filename: %s", source, output_filename)
    r = requests.get(url)
    r.raise_for_status()
    d = r.text
    Path(output_filename).write_text(d)
    return d


def download_all_sources(sources):
    for source, files in sources.items():
        download_source(source, f"{source}-nodes.json", files["nodes"])
        download_source(source, f"{source}-grammar.json", files["grammar"])


def write_elisp_file(forms):
    log.info("Writing forms to file")
    with Path("../combobulate-rules.el").open("w") as f:
        def newline():
            f.write("\n")
        def write_form(form, header: str|None=None, footer: str|None=None):
            if header:
                f.write(f";; START {header}")
                newline()
            f.write(form)
            newline()
            if footer:
                f.write(f";; END {footer}")
                newline()
        langs = []
        for src, (form, inv_form) in forms:
            langs.append(src)
            if not form:
                log.error("Skipping %s as it is empty", src)
                continue
            write_form(form, header=f"Production rules for {src}", footer=f"Production rules for {src}")
            write_form(inv_form, header=f"Inverse production rules for {src}", footer=f"Inverse production rules for {src}")
            newline()
        write_form(sexp(
            [
                Symbol("defconst"),
                Symbol(f"combobulate-rules-list"),
                "\n",
                Quote(sexp(sexp(sorted(langs)))),
                "\n",
                LispString("A list of all the languages that have production rules."),
                "\n",
            ]
        ), header="Auto-generated list of all languages", footer="Auto-generated list of all languages")
        newline()
        write_form(sexp(
            [
                Symbol("provide"),
                Quote(Symbol("combobulate-rules")),
            ]
        ))


def parse_source(language, source):
    log.info("Parsing language %s with node file %s", language, source)
    data = load_node_types(source)
    rules, inv_rules = process_rules(data)
    return generate_sexp(rules, inv_rules, language, source)

def read_sources(sources_file: str) -> dict:
    # Create a ConfigParser object
    sources = {}
    config = configparser.ConfigParser()
    config.read(sources_file)
    for section in config.sections():
        sources[section] = dict(config[section])
    return sources

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--download", action="store_true", help="Download sources first", default=False
    )
    parser.add_argument(
        "--sources-file", action="store", help="Sources file", default="sources.ini"
    )
    args = parser.parse_args()
    forms = []
    sources = read_sources(args.sources_file)
    if args.download:
        download_all_sources(sources)

    for src, files in sources.items():
        forms.append((src, parse_source(src, Path(f"{src}-nodes.json"))))
    write_elisp_file(forms)


if __name__ == "__main__":
    main()
