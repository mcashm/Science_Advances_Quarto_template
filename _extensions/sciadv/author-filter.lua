-- Lua filter to format authors for Science Advances template

function Meta(meta)
  if meta.author and meta.author.t == "MetaList" then
    local author_names = {}
    local affiliations = {}
    local affil_map = {}
    local affil_num = 1
    local corresponding_email = nil
    
    -- Process each author
    for i, author in ipairs(meta.author) do
      if author.t == "MetaMap" then
        local name = pandoc.utils.stringify(author.name or "")
        local superscripts = {}
        
        -- Process affiliations
        if author.affiliations and author.affiliations.t == "MetaList" then
          for _, affil in ipairs(author.affiliations) do
            local affil_text = pandoc.utils.stringify(affil)
            if not affil_map[affil_text] then
              affil_map[affil_text] = affil_num
              table.insert(affiliations, {
                num = affil_num,
                text = affil_text
              })
              affil_num = affil_num + 1
            end
            table.insert(superscripts, tostring(affil_map[affil_text]))
          end
        end
        
        -- Build author string with superscripts
        local author_str = name
        if #superscripts > 0 then
          author_str = author_str .. "^" .. table.concat(superscripts, ",") .. "^"
        end
        
        -- Mark corresponding author
        if author.corresponding and author.corresponding.c then
          author_str = author_str .. "*"
          if author.email then
            corresponding_email = pandoc.utils.stringify(author.email)
          end
        end
        
        table.insert(author_names, author_str)
      end
    end
    
    -- Create formatted strings for LaTeX
    if #author_names > 0 then
      meta['author-string'] = pandoc.MetaInlines(pandoc.RawInline('latex', table.concat(author_names, ', ')))
    end
    
    -- Create affiliation list
    local affil_latex = {}
    for _, affil in ipairs(affiliations) do
      table.insert(affil_latex, '\\textsuperscript{' .. affil.num .. '}' .. affil.text)
    end
    if #affil_latex > 0 then
      meta['affiliation-string'] = pandoc.MetaInlines(pandoc.RawInline('latex', table.concat(affil_latex, '\\\\\n')))
    end
    
    -- Add corresponding email
    if corresponding_email then
      meta['corresponding-email'] = pandoc.MetaInlines(pandoc.RawInline('latex', '*Corresponding author. Email: ' .. corresponding_email))
    end
  end
  
  return meta
end

return {
  { Meta = Meta }
}
