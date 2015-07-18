require 'sinatra/base'

module Sinatra
  module TalentFunctions
    
    def pass_parsed_talent
      name = "Even More Quicker Strike"
      text = "Add [:b:] [:a:] [:p:] per rank of Quick [:ad:] Strike [:s:] to combat [:d:] checks against [:f:] targets [:su:] that have [:c:] not acted [:tr:] yet this [:f:] encounter [:th:] to combat [:fl:] checks [:fa:] against targets [:fd:] that have not [:fr:] acted yet [:ds:] this encounter."
      cost = "10"
      split_title = split_text_by_length(name, 15)
      split_description = split_text_by_length(text, 30)
      return [split_title, split_description, cost]
    end
    
    def gen_svg_paths(name_lines, description_lines)
      # The default path array
      box_outline = [[0, 0], [207, 0], [222, 13], [222, 127], [207, 142], [13,142], [0, 127]]
      box_contents = [[3, 3], [205, 3], [219, 15], [219, 125], [205, 139], [15, 139], [3, 125]]
      title_box = [[10, 10], [194, 10], [210, 27], [210,27], [194, 42], [10, 42]]
      check_box = [[193, 15], [204, 26], [193, 37], [182, 26]]
      check_box_detailing = [[186, 15], [188, 17], [179, 26], [188, 35], [186, 37], [175, 26]]
      cost_box = [[210, 139], [199, 128], [148, 128], [137, 139], [146, 150],[199, 150]]
      title_xy = [[15, 33]]
      text_xy = [[15, 60]]
      cost_xy = [[148, 144]]
        
      if name_lines > 1
        y_offset = 28*(name_lines-1)
        # Move the box's bottom edge down
        box_outline  = apply_offsets(box_outline, 0, y_offset, 3..6)
        box_contents = apply_offsets(box_contents, 0, y_offset, 3..6)
        # Shift the title
        title_box = apply_offsets(title_box, 0, y_offset, 3..5)
        # Shift the check box and detailing
        check_box = apply_offsets(check_box, 0, y_offset/2)
        check_box_detailing = apply_offsets(check_box_detailing, 0, y_offset/2)
        # Shift the cost box
        cost_box = apply_offsets(cost_box, 0, y_offset)
        # Shift the cost text
        cost_xy = apply_offsets(cost_xy, 0, y_offset)
        # Shift the text start
        text_xy = apply_offsets(text_xy, 0, y_offset)
      end
      if description_lines > 5
        y_offset = 15*(description_lines-5)
        # Move the box's bottom edge down
        box_outline  = apply_offsets(box_outline, 0, y_offset, 3..6)
        box_contents = apply_offsets(box_contents, 0, y_offset, 3..6)
        # Shift the cost box
        cost_box = apply_offsets(cost_box, 0, y_offset)
        # Shift the cost text
        cost_xy = apply_offsets(cost_xy, 0, y_offset)
      end
      
    return {:outline => box_outline, :contents => box_contents, :title_box => title_box, 
            :checkbox => check_box, :checkbox_details => check_box_detailing,
            :cost_box => cost_box, :title => title_xy, :text => text_xy, :cost => cost_xy}
    end
    
    def apply_offsets(arr, x_off, y_off, range = nil)
      if range
        for i in range
          arr[i][0] += x_off
          arr[i][1] += y_off
        end
      else
        for i in 0...arr.length
          arr[i][0] += x_off
          arr[i][1] += y_off
        end
      end
      return arr
    end
    
    def arr_to_path(arr)
      path = ""
      for i in 0...arr.length
        if i > 0
          path << " "
        end
        path << "#{arr[i][0]},#{arr[i][1]}"
      end
      return path
    end
    
    def is_glyph_char?(text)
      glyphs_data = {
        "[:b:]"  => ["boost", "b"],
        "[:a:]"  => ["ability", "d"],
        "[:p:]"  => ["proficiency", "c"],
        "[:s:]"  => ["setback", "b"],
        "[:d:]"  => ["difficulty", "d"],
        "[:c:]"  => ["challenge", "c"],
        "[:f:]"  => ["force", "c"],
        "[:fl:]" => ["force-light", "z"],
        "[:fd:]" => ["force-dark", "z"],
        "[:fa:]" => ["force-agnostic", "*"],
        "[:ad:]" => ["advantage", "a"],
        "[:su:]" => ["success", "s"],
        "[:tr:]" => ["triumph", "x"],
        "[:th:]" => ["threat", "t"],
        "[:fr:]" => ["failure", "f"],
        "[:ds:]" => ["despair", "y"]
      }
      # checks if the text follows the pattern "[:aa:]"
      if text =~ /^\[:\w{1,2}:\]$/
        # If it does, replace it with the relevant unicode
        text = "<tspan class=\"eote-symbol #{glyphs_data[text][0]}\">#{glyphs_data[text][1]}</tspan>"
        return [true, text]
      else
        return [false, text]
      end
    end
    
    def converted_length(arr, index)
      if is_glyph_char?(arr[index])[0]
        return 2
      else
        return arr[index].length
      end
    end
    
    def split_text_by_length (text, max_length)
      split_text = text.split(" ")
      char_count = 0
      tmp = ""
      string_arr = []
      for i in 0...split_text.length
        if char_count > 0
          tmp << " "
          char_count += 1
        end
        tmp << is_glyph_char?(split_text[i])[1]
        char_count += converted_length(split_text, i)
        if (split_text[i+1] && (char_count + 1 + converted_length(split_text, i+1)) > max_length)
          string_arr << tmp
          tmp = ""
          char_count = 0
        end
      end
      string_arr << tmp
      return string_arr
    end
    
    def pass_width_height
      max_x = -1
      max_y = -1
      @svg_locs.each do |key, value|
        value.each do |pair|
          pair[0] > max_x ? max_x = pair[0] : nil
          pair[1] > max_y ? max_y = pair[1] : nil
        end
      end
      return [max_x, max_y]
    end
  end
  
  helpers TalentFunctions
end