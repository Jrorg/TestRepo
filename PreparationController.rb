
class PreparationController < BaseController
	include Singleton

	def initialize
		super
		return if (!@valid)
		if ( (!@view_obj) || (!@model_class) )
		  @valid=false
		  return
		end 
	end
	
	#If this method is called, irrespective of model type, model name it return SiteModel's singletone instance
	def get_mobj(mname=nil) @model_class.instance; end

  #* Get list of model object names corresponds to this controller	 	 
  #* Calls show_site_form of @view_obj to show the initialize site form
  #* Since site is Singleton class, it gets the current SiteModel instance alone	 
	def do_initialize(wdialog, pstr_a=[])
		return false if (!valid)
		mobj = get_mobj()
		if(!mobj.valid)
			SD::Log.uimsg("Err","Site Information has to be set before performing this operation")
			@view_obj.reset_form_change(wdialog)
			MenuView.instance.show_menu(wdialog, 'site')
			return false
		end
		face_a = SkpOp.get_all_ground
		if(face_a.empty?)
			SD::Log.uimsg("Err","Ground face does not have a name. Please set in Site before performing this operation")
			@view_obj.reset_form_change(wdialog)
			MenuView.instance.show_menu(wdialog, 'site')
			return false
		end
		res = do_show_default_unit(wdialog)
		res = do_show_site_information(wdialog)
		return res
	end#do_initialize

  #* Implement tools Apply in site screen
  #* Input: <i>pstr_a[0] : tool name.  One of the following
  #*          'boundary_offset', 'maintenance_offset', 'obstruction_height', 'named_region', 'keepout_region'
  #* Output: Return true if success else false
  #* ######## Check Azimuth implementation
  
	def do_preparation_tool_apply(wdialog, pstr_a=[])
		return false if (!valid)
		return false if ( (!pstr_a.is_a?(Array))  || (pstr_a.empty?) )	  
		if NameRegionTool.instance.has_multiple_regions?
			do_select_region_name wdialog, :callback => 'execute_preparation_tool_apply', :callback_params => pstr_a[0]
		else
			#only one region			
			execute_preparation_tool_apply wdialog, pstr_a
		end
	end
  
  
  def execute_preparation_tool_apply(wdialog, pstr_a=[])
    return false if (!valid)
    return false if ( (!pstr_a.is_a?(Array)) || (pstr_a.empty?) )
    curr_tool = nil
    t_h = SD::str2hash(pstr_a[0])    
        
    toolname = t_h['tool']
    if toolname == nil
		toolname = pstr_a[0]
	end
	
	unit_str = SkpOp.get_defaultUnit
	rname = NameRegionTool.instance.get_current_region_name
    case toolname
      when 'boundary_offset'
        offset = (t_h['offset']) ? t_h['offset'].to_f : 0  
        if(unit_str != "in")
			offset = offset.mu_2_inch(unit_str).round_to(3)
		end           
        return true if (!rname) ## user pressed Cancel
        gnd = SkpOp.get_ground(rname)
        ## Check whether we can draw boundary offset on this ground
        res = SkpOp.check_boundary_draw(gnd)
        case res
          when 'Not Valid Ground'
            SD::Log.uimsg("Not able to get a valid face for the given region name.  Please run Model cleanup and restart.")
            return false
          when 'Boffset Present'
            SD::Log.uimsg("Selected region has boundary offset already rendered. Cannot be selected again.")
            return false
          when "Higher Layer"
            SD::Log.uimsg("Selected region has layout operations performed already. Cannot render boundary offset.")
            return false
          end
        res = SkpOp.set_boundary_offset(gnd,rname,offset)
        if (!res)
          SD::Log.uimsg("Failure in rendering boundary offset.")
          return false
        else
          SD::Log.uimsg("Boundary offset set successfully.")
          @view_obj.reset_form_change(wdialog)
          return true
        end
	  when 'maintenance_offset'
        offset = (t_h['offset']) ? t_h['offset'].to_f : 0
        if(unit_str != "in")
			offset = offset.mu_2_inch(unit_str).round_to(3)
		end

        curr_tool = MaintenanceKeepoutTool.instance
        curr_tool.set_offset(offset)

        return true if (!rname) ## user pressed Cancel

        gnd = SkpOp.get_ground(rname)
        res=curr_tool.set_ground(rname,gnd)
        case res
          when 'Not Valid Ground'
            SD::Log.uimsg("Not able to get a valid face for the given region name.  Please run Model cleanup and restart.")
            return false
          when 'Mkeepout Present'
            SD::Log.uimsg("Selected region has maintenance keepout already rendered. Cannot be selected again.")
            return false
          when "Higher Layer"
            SD::Log.uimsg("Selected region has layout operations performed already. Cannot render maintenance keepout.")
            return false
          end
          @view_obj.reset_form_change(wdialog)
      when 'obstruction_height'      
        curr_tool = ObstructionHeightTool.instance
      else
        SD::Log.msg('Info', "Tool Not yet implemented")
        return false
    end
    if (SkpOp)
	 Sketchup.active_model.select_tool(curr_tool)
    else
     SD::Log.msg('Info', "Currently Selected toold", curr_tool)
    end

  end#do_site_tool_apply

  #* Implement tools Apply in preparation screen
  #* Input: <i>pstr_a[0] : tool name.  One of the following
  #*          'boundary_offset', 'obstruction_height', 'maintenance_offset', 'named_region', 'keepout_region'
  #* Output: Return true if success else false
  
	def do_preparation_tool_undo(wdialog, pstr_a=[])
		return false if (!valid)
		return false if ( (!pstr_a.is_a?(Array))  || (pstr_a.empty?) )	  
		if NameRegionTool.instance.has_multiple_regions?
			do_select_region_name wdialog, :callback => 'execute_preparation_tool_undo', :callback_params => pstr_a[0]
		else
			#only one region
			execute_preparation_tool_undo wdialog, pstr_a
		end
	end
  
  def execute_preparation_tool_undo(wdialog,pstr_a=[])
    return false if (!valid)
    return false if ( (!pstr_a.is_a?(Array)) || (pstr_a.empty?) )
    toolname = pstr_a[0].strip.downcase 
    inst = nil
	rname = NameRegionTool.instance.get_current_region_name
    case toolname
    when 'boundary_offset'
      return true if (!rname) ## user pressed Cancel

      gnd = SkpOp.get_ground(rname)
      res = SkpOp.check_boundary_undo(gnd,rname)
      case res
        when 'Nothing to Undo'
          SD::Log.uimsg("No boundary offset found in selected region. Nothing to undo.")
          return false
        when 'Not Valid Ground'
          SD::Log.uimsg("Not able to get a valid face for the given region name.  Please run Model cleanup and restart.")
        return false
        when "Higher Layer"
          SD::Log.uimsg("Selected region has layout operations performed already. Cannot undo boundary offset.") 
        return false
      end
      res = SkpOp.clear_boundary_offset(gnd,rname)
      if (!res)
        SD::Log.uimsg("Boundary offset undo failed.")
        return false
      else
        SD::Log.uimsg("Boundary offset undo completed.")
        return true
      end
    when 'maintenance_offset'
      inst = MaintenanceKeepoutTool.instance
      return true if (!rname) ## user pressed Cancel

      gnd = SkpOp.get_ground(rname)
      res = inst.check_ground_undo(gnd,rname)
      case res
        when 'Nothing to Undo'
          SD::Log.uimsg("No maintenance keepout found in selected region. Nothing to undo.")
          return false
        when 'Not Valid Ground'
          SD::Log.uimsg("Not able to get a valid face for the given region name.  Please run Model cleanup and restart.")
        return false
        when "Higher Layer"
          SD::Log.uimsg("Selected region has layout operations performed already. Cannot undo maintenance keepout.") 
        return false
        when "Success"
          ## Continue
      end
      res = inst.clear_maintenance_keepout(rname)
      if (!res)
        SD::Log.uimsg("Maintenance keepout undo failed.")
        return false
      else
        return true
      end
    else 
      SD::Log.msg('Info', "#{toolname} undo not implemented")
      return false
    end 
    return true

  end

end#PreparationController
