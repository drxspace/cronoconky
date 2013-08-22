package.path = os.getenv ('HOME').."/.conky/cronograph_se/scripts/?.lua"

require 'clock_rings' 
require 'multi_rings'

function conky_main()
     conky_clock_rings()
     conky_multi_rings()
end

