<?php

function pass(){
echo("joie");
}

class Awesome{

function __construct(){
pass();
}

function x(){
return(2 + 2);
}

function z(){
print("poulet");
}

}

$poulet = true;
if ($poulet) {
$aw = $new = new Awesome("brilliant!",2);
$pouti = $aw->x();
$awe = $aw->init()->x()->z();
print($awe);
} else {
weird();
}
