<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
//The boat sends its URL and requests the data of the sim 

$headers    = apache_request_headers();
$objectgrid = $headers["X-Secondlife-Shard"];
$objectname = $headers["X-Secondlife-Object-Name"];
$objectkey  = $headers["X-Secondlife-Object-Key"];
$objectpos  = $headers["X-Secondlife-Local-Position"];
$ownerkey   = $headers["X-Secondlife-Owner-Key"];
$ownername  = $headers["X-Secondlife-Owner-Name"];
$regiondata = $headers["X-Secondlife-Region"];
$regiontmp  = explode ("(",$regiondata);        // cut cords off
$regionpos  = explode (")",$regiontmp[1]);
$regionpos  = explode (",",$regionpos[0]);
$regionname = substr($regiontmp[0],0,-1);       // cut last space from simname

$data       = file_get_contents("php://input");
$cols       = explode(",",$data);
require '../../glwdb.php';


$nt=count($cols);
if($nt!=2) die("KOError parameters number");

$idEvents=(integer)$cols[0];
$idBoat=(integer)$cols[1];
$boatKey=$cols[2];
if ($idEvents == 0) {
    die("KOError id of event");
}else if ($idBoat == 0) {
    die("KOError id of boat");
}

$boatSimX=(integer)($regionpos[0]/256);
$boatSimY=(integer)($regionpos[1]/256);
$boatpostmp=substr($objectpos,1,-2);
$boatposcoord=explode(",",$boatpostmp);
$boatX=(integer)($boatposcoord[0]+0.5);
$boatY=(integer)($boatposcoord[1]+0.5);

$regionname=str_replace("'","''",$regionname);
$sql="UPDATE glwBoats SET boatSimName='$regionname',boatSimX=$boatSimX,boatSimY=$boatSimY,
        boatX=$boatX,boatY=$boatY WHERE id=$idBoat";
if($conn->query($sql)) {
    echo "OK";
}else{
    echo "KOError update pos: " . $sql . "\n" . $conn->error;
}
$conn->close();
?>


























