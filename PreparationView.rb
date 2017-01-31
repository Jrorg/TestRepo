=begin rdoc
===Summary
 * Example code for PreparationView 

=end

class PreparationView < BaseView
	include Singleton 

	#------------------------------------------- Methods -------------------------------------------#
	def initialize
		@schema = MVSchema.get_preparationview_schema
		super
	end #initialize

	def click_code
		script_str = %Q{
			<script type="text/javascript">		
			$(function(){	
			
                $(".#{@mkey}_tool").click(function(event) {
					var toolName = $(this).data('tool');				
					var actionName = $(this).data('action');					
                    if ( actionName == 'apply' )   
                    {
                        if ( toolName=='maintenance_offset' || toolName=='boundary_offset' ) 
                        {
							var offsetStr = $('##{@mkey}_'+toolName).val();
							var offset = parseFloat(offsetStr)
							if (!offset || isNaN(offset)) 
							{ 
								alert('Offsets have to be in decimal number format.');
							} 
							else
							{
								var str = "tool="+toolName+"&offset="+offset;
								execute('#{@mkey}','do_preparation_tool_apply', str);
							}
						}
						else	//boundary offset
						{							
							execute('#{@mkey}','do_preparation_tool_apply', toolName)					
						}
					}
					else
						execute('#{@mkey}','do_preparation_tool_undo',toolName);
				});	
			});
			</script>
		}
		return script_str
	end #click_code
	
	#html code for the form UI 
	def html_code
		return "" if (!@valid)	 
		content_str = %Q{
		<div id="#{@mkey}_content">
			<form id="#{@mkey}_form" class="form-content-class">	
				#{site_information_html_code :hide_major_components=>true}
				<div class="tools-class"><table name="#{@mkey}_table" id="#{@mkey}_table">		
					<tr>
						<td><b>1</b>.</td>
						<td> <label for="#{@mkey}_boundary_offset">Boundary Offset </label><span name="unitlabel"> </span> </td> 
						<td colspan="2"> <input name="#{@mkey}_boundary_offset" id="#{@mkey}_boundary_offset" type="text" size="5"> </td>
						<td>
							<button class="sundat-play sundat-icon-only #{@mkey}_tool"  title="Apply" data-tool="boundary_offset" data-action="apply">Play</button>
						</td>
						<td>
							<button class="sundat-undo sundat-icon-only #{@mkey}_tool"  title="Undo" data-tool="boundary_offset" data-action="undo">Undo</button>
						</td>										
					</tr>			
					<tr>
						<td><b>2</b>.</td>
						<td colspan="3"> <label>Obstruction Height Tool </label></td>
						<td>
							<button class="sundat-play sundat-icon-only #{@mkey}_tool"  title="Apply" data-tool="obstruction_height" data-action="apply">Play</button>
						</td>								
					</tr>										
					<tr>
						<td><b>3</b>.</td>
						<td> <label for="#{@mkey}_maintenance_offset">Maintenance Offset </label> <span name="unitlabel"> </span> </td>
						<td colspan="2"> 
							<input name="#{@mkey}_maintenance_offset" id="#{@mkey}_maintenance_offset" type="text" size="5">
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						</td>
						<td>
							<button class="sundat-play sundat-icon-only #{@mkey}_tool"  title="Apply" data-tool="maintenance_offset" data-action="apply">Play</button>
						</td>
						<td>
							<button class="sundat-undo sundat-icon-only #{@mkey}_tool"  title="Undo" data-tool="maintenance_offset" data-action="undo">Undo</button>
						</td>
					</tr>																							
				</table></div>		  
			</form>
		</div>
		}	  
		return content_str
	end #html_code
     	 	
end #PreparationView

