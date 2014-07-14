# http://daringfireball.net/projects/markdown
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufSetOption mimetype=text/x-markdown %{
    set buffer filetype markdown
}

hook global BufCreate .*[.](markdown|md) %{
    set buffer filetype markdown
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

addhl -group / regions -default content markdown \
    sh         ```sh   ```                    '' \
    fish       ```fish ```                    '' \
    ruby       ```ruby ```                    '' \
    code       ```     ```                    '' \
    code       ``       ``                    '' \
    code       `         `                    ''

addhl -group /markdown/code fill meta

addhl -group /markdown/sh   ref sh
addhl -group /markdown/fish ref fish
addhl -group /markdown/ruby ref ruby

# Setext-style header
addhl -group /markdown/content regex (\A|\n\n)[^\n]+\n={2,}\h*\n\h*$ 0:blue
addhl -group /markdown/content regex (\A|\n\n)[^\n]+\n-{2,}\h*\n\h*$ 0:cyan

# Atx-style header
addhl -group /markdown/content regex ^(#+)(\h+)([^\n]+) 1:red

addhl -group /markdown/content regex ^\h+([-\*])\h+[^\n]*(\n\h+[^-\*]\S+[^\n]*)*$ 0:yellow 1:cyan
addhl -group /markdown/content regex ^([-=~]+)\n[^\n\h].*?\n\1$ 0:magenta
addhl -group /markdown/content regex (?<!\w)\+[^\n]+?\+(?!\w) 0:green
addhl -group /markdown/content regex (?<!\w)_[^\n]+?_(?!\w) 0:yellow
addhl -group /markdown/content regex (?<!\w)\*[^\n]+?\*(?!\w) 0:red
addhl -group /markdown/content regex <[a-z]+://.*?> 0:cyan
addhl -group /markdown/content regex ^\h*(>\h*)+ 0:comment
addhl -group /markdown/content regex \H\K\h\h$ 0:PrimarySelection

# Commands
# ‾‾‾‾‾‾‾‾

def -hidden _markdown_filter_around_selections %{
    eval -draft -itersel %{
        exec <a-x>
        # remove trailing white spaces
        try %{ exec -draft s \h+$ <ret> d }
    }
}

def -hidden _markdown_indent_on_new_line %{
    eval -draft -itersel %{
        # preserve previous line indent
        try %{ exec -draft <space> K <a-&> }
        # filter previous line
        try %{ exec -draft k : _markdown_filter_around_selections <ret> }
        # copy block quote(s), list item prefix and following white spaces
        try %{ exec -draft k x s ^\h*\K((>\h*)|[*+-])+\h* <ret> y j p }
    }
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=markdown %{
    addhl ref markdown

    hook window InsertEnd  .* -group markdown-hooks  _markdown_filter_around_selections
    hook window InsertChar \n -group markdown-indent _markdown_indent_on_new_line
}

hook global WinSetOption filetype=(?!markdown).* %{
    rmhl markdown
    rmhooks window markdown-indent
    rmhooks window markdown-hooks
}
