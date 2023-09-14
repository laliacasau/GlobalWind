<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
// Mind that some headers are not included because they're either useless or unreliable. X-Secondlife-Local-Position 
$headers    = apache_request_headers();
$objectgrid = $headers["X-Secondlife-Shard"];
$objectname = $headers["X-Secondlife-Object-Name"];
$objectkey  = $headers["X-Secondlife-Object-Key"];
$objectpos  = $headers["X-Secondlife-Local-Position"];
$ownerkey   = $headers["X-Secondlife-Owner-Key"];
$ownername  = $headers["X-Secondlife-Owner-Name"];
$regiondata = $headers["X-Secondlife-Region"];
$regiontmp  = explode ("(",$regiondata);            // cut cords off
$regionname = substr($regiontmp[0],0,-1);           // cut last space from simname
$regiontmp  = explode (")",$regiontmp[1]);
$regionpos  = $regiontmp[0];

$data       = file_get_contents("php://input");
$listas     = explode("#",$data);
$control    = $listas[0];
//$wind      = explode(",",$listas[1]);
require '../../glwdb.php';

//update world wind data
$wind=$listas[1];
$sql="UPDATE glwWorldBase SET baseWind='".$wind."' WHERE code=1";
if($conn->query($sql)) {
    echo "OK";
}else{
    die("KOError: " . $sql . "\n" . $conn->error);
}

?>


























