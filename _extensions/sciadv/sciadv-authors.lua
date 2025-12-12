-- Pre-filter that runs before Quarto's author processing
-- This extracts author information and creates simple template variables

local AFFILIATION_SEPARATOR = '\\\\\n'

local function process_authors(meta)
  if not meta.author then
    return meta
  end
  
  -- Quarto hasn't processed authors yet, so we have the full structure
  local author_names = {}
  local affiliations = {}
  local affil_map = {}
  local affil_num = 1
  local corresponding_email = nil
  local author_count = 0
  
  -- Check if we have a list of authors
  for i, author_item in ipairs(meta.author) do
    author_count = author_count + 1
    local author = author_item
    
    -- Get author name
    local name = ""
    if author.name then
      name = pandoc.utils.stringify(author.name)
    end
    
    local superscripts = {}
    
    -- Process affiliations if they exist
    if author.affiliations then
      for _, affil in ipairs(author.affiliations) do
        local affil_text = pandoc.utils.stringify(affil)
        if affil_text and affil_text ~= "" then
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
    end
    
    -- Build author string
    local author_str = name
    if #superscripts > 0 then
      author_str = author_str .. "\\textsuperscript{" .. table.concat(superscripts, ",") .. "}"
    end
    
    -- Check if corresponding author
    if author.corresponding then
      author_str = author_str .. "*"
      if author.email then
        corresponding_email = pandoc.utils.stringify(author.email)
      end
    end
    
    if name ~= "" then
      table.insert(author_names, author_str)
    end
  end
  
  -- Only set these if we found authors
  if #author_names > 0 then
    meta['sciadv-author-string'] = pandoc.MetaInlines(pandoc.RawInline('latex', table.concat(author_names, ', ')))
  end
  
  if #affiliations > 0 then
    local affil_lines = {}
    for _, affil in ipairs(affiliations) do
      table.insert(affil_lines, '\\textsuperscript{' .. affil.num .. '}' .. affil.text)
    end
    meta['sciadv-affiliation-string'] = pandoc.MetaInlines(pandoc.RawInline('latex', table.concat(affil_lines, AFFILIATION_SEPARATOR)))
  end
  
  if corresponding_email then
    meta['sciadv-corresponding-email'] = pandoc.MetaInlines(pandoc.RawInline('latex', '*Corresponding author. Email: ' .. corresponding_email))
  end
  
  return meta
end

return {
  {
    Meta = process_authors
  }
}
