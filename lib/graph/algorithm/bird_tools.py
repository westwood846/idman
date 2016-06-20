# -*- coding: utf-8 -*-
import re


def normalize_name(name):
    # We remove all punctuation, suffixes
    # ("jr"); turn all whitespace into a single space; remove
    # generic terms like "admin", "support", from the name;
    """

    :param name:
    :return:
    """
    prefixes = ["mr.", "mrs.", "miss", "ms.", "prof.", "pr.", "dr.", "ir.", "rev.", "ing.", "jr.",
                "d.d.s.", "ph.d.",
                "capt.", "lt."]
    tech_terms = ["administrator", "admin.", "support", "development", "dev.", "developer", "maint.",
                  "maintainer"]
    # other_terms = ["i18n", "spam", "bug", "bugs", "root", "mailing", "list", "contact", "project"]
    project_specific_terms = ["elasticsearch", "gdx", "libgdx", "spring", "spring-framework", "django"]
    custom_terms = ["github"]
    insignificant_words = prefixes + tech_terms + project_specific_terms + custom_terms
    for term in insignificant_words:
        term_re = re.compile(re.escape(term), re.IGNORECASE)
        name = term_re.sub("", name).strip()
    # The paper does not mention case-sensitivity, but we obviously need to do this case-insensitive
    return name.lower()


def extract_mail_prefix(mail):
    """

    :param mail:
    :return:
    """
    return mail.split("@")[0].lower()


def split_name(name):
    """

    :param name:
    :return:
    """
    split = name.split(" ")  # TODO: Split commas
    return " ".join(split[:-1]), split[-1]


def join_name(firstname, lastname):
    """

    :param firstname:
    :param lastname:
    :return:
    """
    return " ".join([firstname, lastname])
