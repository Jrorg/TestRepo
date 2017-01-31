=begin
SunEdison (c) 2013
sundat_loader.rb
=end
if (defined?(Settings))
  UI.messagebox("SunDAT V1 is already loaded, hence V2 cannot be loaded now. \n\n"+
            "Deselect SunDAT V1 in Window->Preferences->Extensions and restart Sketchup to use V2")
else
  #~ Use only forward slash (/) as path separator and string should be with double quotes
  $sundat_root    = "D:/Projects/SundatWorkingVersion"
  fname = File.join($sundat_root, "boot_loader.rb")
  fname = File.join($sundat_root, "boot_loader.rbs") if (!File.exist?(fname))
  if (File.exist?(fname))
    Sketchup.load(fname) 
  else
    UI.messagebox("SunDAT boot loader not available, program not started")
  end
end
