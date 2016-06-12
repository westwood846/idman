# coding=utf-8
import json


class SetEncoder(json.JSONEncoder):
    def default(self, obj):
        """

        :param obj:
        :return:
        """
        if isinstance(obj, set):
            return list(obj)
        return json.JSONEncoder.default(self, obj)
