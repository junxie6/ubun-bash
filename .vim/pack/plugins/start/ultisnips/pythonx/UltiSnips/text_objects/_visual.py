#!/usr/bin/env python
# encoding: utf-8

"""A ${VISUAL}¬†placeholder that will use the text that was last visually
selected and insert it here.

If there was no text visually selected, this will be the empty string.

"""

import re
import textwrap

from UltiSnips import _vim
from UltiSnips.indent_util import IndentUtil
from UltiSnips.text_objects._transformation import TextObjectTransformation
from UltiSnips.text_objects._base import NoneditableTextObject
import platform

_REPLACE_NON_WS = re.compile(r"[^ \t]")


class Visual(NoneditableTextObject, TextObjectTransformation):

    """See module docstring."""

    def __init__(self, parent, token):
        # Find our containing snippet for visual_content
        snippet = parent
        while snippet:
            try:
                self._text = snippet.visual_content.text
                self._mode = snippet.visual_content.mode
                break
            except AttributeError:
                snippet = snippet._parent  # pylint:disable=protected-access
        if not self._text:
            self._text = token.alternative_text
            self._mode = 'v'

        NoneditableTextObject.__init__(self, parent, token)
        TextObjectTransformation.__init__(self, token)

    def _update(self, done):
        if self._mode == 'v':  # Normal selection.
            if platform.system() == 'Windows':
                # Remove last character for windows in normal selection.
                text = self._text[:-1]
            else:
                text = self._text
        else:  # Block selection or line selection.
            text_before = _vim.buf[self.start.line][:self.start.col]
            indent = _REPLACE_NON_WS.sub(' ', text_before)
            iu = IndentUtil()
            indent = iu.indent_to_spaces(indent)
            indent = iu.spaces_to_indent(indent)
            text = ''
            for idx, line in enumerate(textwrap.dedent(
                    self._text).splitlines(True)):
                if idx != 0:
                    text += indent
                text += line
            text = text[:-1]  # Strip final '\n'

        text = self._transform(text)
        self.overwrite(text)
        self._parent._del_child(self)  # pylint:disable=protected-access

        return True
