    
@array = 'a' .. 'z';
for($i=0,$item= $array[$i] ; $item = $array[$i]; $i++ ){
    warn $item;
}

