from pygments.lexer import RegexLexer
from pygments import token
from sphinx.highlighting import lexers

__version__ = '0.0.1'

class AlbaLexer(RegexLexer):
    name = 'alba'
    aliases = ['Alba']
    filenames = ['*.al', '*.ali']
    mimetypes = ['text/x-alba']

# token types:
#   Error, Whitespace, Number, String, Literal, Operator,
#   Comment, Punctuation, Name, Other, Keyword, Generic

    tokens = {
        'root': [
            (r'\s+',        token.Text),
            (r'--.*',       token.Comment.Singleline),
            (r'{-',         token.Comment.Multiline, 'comment'),
            (r'all|and|case|class|inspect|mutual|not|or|where',
                token.Keyword),
            (r'[a-zA-Z][a-zA-Z_0-9]*',   token.Name),
            (r'[0-9]+',     token.Number),
            (r'[+*/:=~\\-]',token.Operator),
            (r'.',          token.Text)
        ],
        'comment': [
            (r'[^-]',       token.Comment.Multiline),
            (r'-}',         token.Comment.Multiline, '#pop'),
            (r'-',          token.Comment.Multiline)
        ]

    }

#lexers['alba'] = AlbaLexer(startinline=True)
lexers['alba'] = AlbaLexer()

def setup (app):
    return {'version' : '0.0.1'}
