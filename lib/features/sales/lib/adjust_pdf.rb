# module to gather methods used in quotes, invoices and delivery notes controllers to adjust pdf footlines
module AdjustPdf
  private
    def adjust_pdf_last_footline(area_tree_path,optimum_footline_offset_value_for_first_page,optimum_footline_offset_value_for_other_page) 
      total_pages = `xpath -e "count(//page)" #{area_tree_path}`.to_i
      footlines_offsets_values = `xpath -e "//block[@prod-id='footline']/@top-offset" #{area_tree_path}`.scan(/[0-9]+/)
      last_offset_value = footlines_offsets_values.last.to_i
      
      if total_pages == 1
        optimum_offset_value = optimum_footline_offset_value_for_first_page # FIXME This value has to change if the total height of elements before the table change
      else
        optimum_offset_value = optimum_footline_offset_value_for_other_page # This value should normally be constant
      end
      
      if last_offset_value < optimum_offset_value
        additionnal_last_offset_value = optimum_offset_value - last_offset_value
        @new_padding_for_last_offset = (additionnal_last_offset_value * 0.0000325) + 0.1
      end 
    end

    def adjust_pdf_intermediate_footlines(area_tree_path,optimum_footline_offset_value_for_first_page,optimum_footline_offset_value_for_other_page) 
      footlines_offsets_values = `xpath -e "//block[@prod-id='footline']/@top-offset" #{area_tree_path}`.scan(/[0-9]+/)
      footlines_prod_ids_pages = `xpath -e "//block[@prod-id='footline']/ancestor::pageViewport/@nr" #{area_tree_path}`.scan(/[0-9]+/)
      
      cells_prod_ids_pages = `xpath -e "//*[contains(@prod-id,'cell')]/ancestor::pageViewport/@nr" #{area_tree_path}`.scan(/[0-9]+/)
      cells_prod_ids = `xpath -e "//*[contains(@prod-id,'cell')]/@prod-id" #{area_tree_path}`.scan(/[0-9]+/)
      
      @footlines_adjustments = Hash.new
      
      footlines_offsets_values.each do |footline_value|
        unless footline_value.to_i == footlines_offsets_values.last.to_i
          footline_page = footlines_prod_ids_pages[footlines_offsets_values.index(footline_value.to_s)]
          last_cell_id_index = cells_prod_ids_pages.length - cells_prod_ids_pages.reverse.index(footline_page).to_i - 1
          last_cell_id = cells_prod_ids[last_cell_id_index]
          
          if footline_page.to_i == 1
            optimum_offset_value = optimum_footline_offset_value_for_first_page # FIXME This value has to change if the total height of elements before the table change
          else
            optimum_offset_value = optimum_footline_offset_value_for_other_page # This value should normally be constant
          end
          
          if footline_value.to_i < optimum_offset_value
            additionnal_footline_offset_value = optimum_offset_value - footline_value.to_i
            @footlines_adjustments[("item_"+last_cell_id.to_s).to_sym] = (additionnal_footline_offset_value * 0.0000325) + 0.3
          end
        end
      end
    end
    
    def adjust_pdf_report(area_tree_path)
      footlines_offsets_values = `xpath -e "//block[@prod-id='footline']/@top-offset" #{area_tree_path}`.scan(/[0-9]+/)
      footlines_prod_ids_pages = `xpath -e "//block[@prod-id='footline']/ancestor::pageViewport/@nr" #{area_tree_path}`.scan(/[0-9]+/)
      
      cells_prod_ids_pages = `xpath -e "//*[contains(@prod-id,'cell')]/ancestor::pageViewport/@nr" #{area_tree_path}`.scan(/[0-9]+/)
      cells_prod_ids = `xpath -e "//*[contains(@prod-id,'cell')]/@prod-id" #{area_tree_path}`.scan(/[0-9]+/)
      
      @report_adjustment = Hash.new
      
      footlines_offsets_values.each do |footline_value|
        footline_page = footlines_prod_ids_pages[footlines_offsets_values.index(footline_value.to_s)]
        first_cell_id_index = cells_prod_ids_pages.index(footline_page).to_i
        first_cell_id = cells_prod_ids[first_cell_id_index]
        
        @report_adjustment[("item_"+first_cell_id.to_s).to_sym] = "true"
      end
    end
end
