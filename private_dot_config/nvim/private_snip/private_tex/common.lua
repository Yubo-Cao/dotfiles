local get_visual = function(args, parent)
  if (#parent.snippet.env.SELECT_RAW > 0) then
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
  else
    return sn(nil, i(1, ''))
  end
end

-- Return snippet tables
return
{
  -- Inline answer
  s({trig = "ians", dscr = "Inline Answer"}, 
    fmta(
      "\\inlineAnswer{<>}",
      {
        d(1, get_visual),
      }
    )
  ),
  -- Answer environemnt
  s({trig = "ans", dscr = "Answer environment"},
    fmta(
      "\\begin{answer}\n\t<>\n\\end{answer}",
      {
        d(1, get_visual),
      }
    )
  ),
}
