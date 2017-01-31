require 'sketchup.rb'
require 'extensions.rb'

sundat_v2_extension = Sketchup.extensions['SunDAT V2']
unless sundat_v2_extension
	sundat_v2_extension             = SketchupExtension.new("SunDAT V2", "D:/Projects/SunDATV2/sundat_loader.rb")
	sundat_v2_extension.name        = 'SunDAT V2'
	sundat_v2_extension.version     = '1.0'
	sundat_v2_extension.description = "SunDAT Version 2.0, supports slopping Roof"
	sundat_v2_extension.copyright   = "2013"
	sundat_v2_extension.creator     = "SunEdison"
	Sketchup.register_extension(sundat_v2_extension, true)
end
