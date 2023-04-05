local get_visual = function(args, parent)
  if (#parent.snippet.env.SELECT_RAW > 0) then
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
  else
    return sn(nil, i(1, ''))
  end
end

-- Math context detection
local tex = {}
tex.in_mathzone = function() return vim.fn['vimtex#syntax#in_mathzone']() == 1 end
tex.in_text = function() return not tex.in_mathzone() end

local line_begin = require("luasnip.extras.expand_conditions").line_begin

-- Return snippet tables
return
  {
    -- General environment
    s({trig="beg"},
      fmta(
        [[
        \begin{<>}
            <>
        \end{<>}
      ]],
        {
          i(1),
          d(2, get_visual),
          rep(1),
        }
      ),
      {condition = line_begin}
    ),
    -- Environment with 1 extra argument
    s({trig="beg2"},
      fmta(
        [[
        \begin{<>}{<>}
            <>
        \end{<>}
      ]],
        {
          i(1),
          i(2),
          d(3, get_visual),
          rep(1),
        }
      ),
      { condition = line_begin }
    ),
    -- Environment with 2 extra arguments
    s({trig="beg3"},
      fmta(
        [[
        \begin{<>}{<>}{<>}
            <>
        \end{<>}
      ]],
        {
          i(1),
          i(2),
          i(3),
          d(4, get_visual),
          rep(1),
        }
      ),
      { condition = line_begin }
    ),
    -- EQUATION
    s({trig="eq"},
      fmta(
        [[
        \begin{equation*}
            <>
        \end{equation*}
      ]],
        {
          i(1),
        }
      ),
      { condition = line_begin }
    ),
    -- SPLIT EQUATION
    s({trig="ss"},
      fmta(
        [[
        \begin{equation*}
            \begin{split}
                <>
            \end{split}
        \end{equation*}
      ]],
        {
          d(1, get_visual),
        }
      ),
      { condition = line_begin }
    ),
    -- Align
    s({trig="all"},
      fmta(
        [[
        \begin{align*}
            <>
        \end{align*}
      ]],
        {
          i(1),
        }
      ),
      {condition = line_begin}
    ),
    -- Itemize
    s({trig="itt"},
      fmta(
        [[
        \begin{itemize}
            \item <>
        \end{itemize}
      ]],
        {
          i(0),
        }
      ),
      {condition = line_begin}
    ),
    -- Enumerate
    s({trig="enn"},
      fmta(
        [[
        \begin{enumerate}
            \item <>
        \end{enumerate}
      ]],
        {
          i(0),
        }
      )
    ),
    -- Description
    s({trig="ddd"},
      fmta(
        [[
        \begin{description}
            \item[<>] <>
        \end{description}
      ]],
        {
          i(0),
          i(1),
        }
      )
    ),
    -- Inline math
    s({trig = "([^%l])mm", regTrig = true, wordTrig = false},
      fmta(
        "<>$<>$",
        {
          f( function(_, snip) return snip.captures[1] end ),
          d(1, get_visual),
        }
      )
    ),
    -- Inline math on new line
    s({trig = "^mm", regTrig = true, wordTrig = false},
      fmta(
        "$<>$",
{
          i(1),
        })),
    -- Figure
    s({trig = "fig"},
      fmta(
        [[
        \begin{figure}[htb!]
          \centering
          \includegraphics[width=<>\linewidth]{<>}
          \caption{<>}
          \label{fig:<>}
        \end{figure}
        ]],
        {
          i(1),
          i(2),
          i(3),
          i(4),
        }
      ),
      { condition = line_begin }
    ),
    -- Emphasis
    s({trig = "em"},
      fmta(
        "\\emph{<>}",
        {
          d(1, get_visual),
        }
      )
    ),
    -- Footnote
    s({trig = "fn"},
      fmta(
        "\\footnote{<>}",
        {
          d(1, get_visual),
        }
      )
    ),
    -- Bold
    s({trig = "tbf"},
      fmta(
        "\\textbf{<>}",
        {
          d(1, get_visual),
        }
      )
    ),
    -- Italic
    s({trig = "tit"},
      fmta(
        "\\textit{<>}",
        {
          d(1, get_visual),
        }
      )
    ),
    -- Underline
    s({trig = "tul"},
      fmta(
        "\\underline{<>}",
        {
          d(1, get_visual),
        }
      )
    ),
    -- Small caps
    s({trig = "tsc"},
      fmta(
        "\\textsc{<>}",
        {
          d(1, get_visual),
        }
      )
    ),
    -- Quantity
    s({trig = ";q"},
      fmta(
        "\\qty{<>}{<>}",
        {
          d(1, get_visual),
          i(2),
        }
      )
    ),
    -- Unit
    s({trig = ";u"},
      fmta(
        "\\unit{<>}",
        {
          d(1, get_visual),
        }
      )
    ),
  }
