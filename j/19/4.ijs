eg =: 228888,111111,123346,123350,123789,123345,123999
input =: 134792 }. i.675810

digits =: 1&$`($:@:(<.@:%&10),10&|)@.(9&<)
goodA =: 0&e.@~:*.]-:/:~
goodB =: (_4&e.+.2&e.)@(-_1&|.)@I.@~:*.]-:/:~
<"0 (] ,. (goodA ,. goodB) @: digits"0) eg
([: +/ (goodA , goodB) @: digits"0) input
