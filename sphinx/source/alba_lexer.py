from pygments.lexer import RegexLexer
from pygments import token
from pygments import style
from sphinx.highlighting import lexers

__version__ = '0.0.1'


class AlbaStyle(style.Style):
    default_style = ""
    styles = {
        token.Comment:                'italic #888',
        token.Keyword:                'bold #005',
        token.Name:                   '#f00',
        token.Name.Function:          '#0f0',
        token.Name.Class:             'bold #0f0',
        token.String:                 'bg:#eee #111'
    }




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
            (r'\b(all|and|case|class|do|else|if|inspect|mutual|not|or|section|then|use|where)\b',
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
