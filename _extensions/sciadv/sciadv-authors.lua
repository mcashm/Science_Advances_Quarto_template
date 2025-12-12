-- Pre-filter that runs before Quarto's author processing
-- This extracts author information and creates simple template variables

local AFFILIATION_SEPARATOR = '\\\\\n'

local function process_authors(meta)
  -- In Quarto 1.5+, the structured author data is in meta.authors (note the plural)
  -- while meta.author contains the simple stringified version
  local authors_meta = meta.authors  -- This should have the full structure
  local affiliations_meta = meta.affiliations  -- This should have affiliations
  
  -- If meta.authors doesn't exist, we can't process structured author data
  -- Don't fallback to meta.author as it may not have the structure we need
  if not authors_meta then
    return meta
  end
  
  -- Quarto may have already processed authors, let's use that
  local author_names = {}
  local affiliations = {}
  local affil_map = {}
  local affil_num = 1
  local corresponding_email = nil
  
  -- Check if affiliations_meta exists and process it
  if affiliations_meta then
    for affil_id, affil in pairs(affiliations_meta) do
      local affil_text = ""
      if affil.name then
        affil_text = pandoc.utils.stringify(affil.name)
        
        -- Add other fields if they exist
        local parts = {}
        if affil.address then
          table.insert(parts, pandoc.utils.stringify(affil.address))
        end
        if affil.city then
          table.insert(parts, pandoc.utils.stringify(affil.city))
        end
        -- Check both 'state' and 'region' for state/province
        if affil.state then
          table.insert(parts, pandoc.utils.stringify(affil.state))
        elseif affil.region then
          table.insert(parts, pandoc.utils.stringify(affil.region))
        end
        if affil["postal-code"] then
          table.insert(parts, pandoc.utils.stringify(affil["postal-code"]))
        end
        
        if #parts > 0 then
          affil_text = affil_text .. ", " .. table.concat(parts, ", ")
        end
        
        -- Store both the numeric ID and potential string ID (e.g., "aff-1" and 1)
        -- This is necessary because Quarto may reference affiliations using different ID formats
        affil_map[tostring(affil_id)] = affil_num
        affil_map[affil_id] = affil_num
        table.insert(affiliations, {
          num = affil_num,
          text = affil_text
        })
        affil_num = affil_num + 1
      end
    end
  end
  
  -- Process authors
  for i, author_item in ipairs(authors_meta) do
    local author = author_item
    
    -- Get author name
    local name = ""
    if author.name then
      -- Check if name is a complex structure with literal field
      if type(author.name) == "table" and author.name.literal then
        name = pandoc.utils.stringify(author.name.literal)
      else
        name = pandoc.utils.stringify(author.name)
      end
    else
      -- Fallback: stringify the whole author
      name = pandoc.utils.stringify(author)
    end
    
    local superscripts = {}
    
    -- Check if author has affiliation references (IDs)
    if author.affiliations then
      for _, affil_ref in ipairs(author.affiliations) do
        -- affil_ref might be an ID (string/number) that references meta.affiliations
        local affil_id = pandoc.utils.stringify(affil_ref)
        
        -- Try direct match first (most common case)
        local affil_num = affil_map[affil_id]
        
        -- If not found, try removing "aff-" prefix
        if not affil_num and affil_id:match("^aff%-") then
          affil_num = affil_map[affil_id:gsub("aff%-", "")]
        end
        
        -- If still not found, try adding "aff-" prefix
        if not affil_num then
          affil_num = affil_map["aff-" .. affil_id]
        end
        
        if affil_num then
          table.insert(superscripts, tostring(affil_num))
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
