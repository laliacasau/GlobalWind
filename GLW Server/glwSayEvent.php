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
$cols       = explode(",",$data);
require '../../glwdb.php';

$posComa=strpos($data,",");
if($posComa>0) $idEvents=(integer)substr($data,0,$posComa);
else $idEvents=0;
if ($idEvents == 0) {
    die("KOError id of event");
}

//call polling function
$return="KOpolling not started";
$data2Send=substr($data,$posComa+1);
$pollMode=3; //info boats
$pollclave="glwSayData"; //key info boats
$pollUrlExtra="";

$sql="SELECT windsetterUrl FROM glwEvents WHERE id=$idEvents";
if($result=$conn->query($sql)){
    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $pollUrlExtra=$row["windsetterUrl"];
        }
    }
}

//need $idEvents, $data2Send, $pollMode
//return $pollreturn
require 'glwPollBoats.php';
//callback function for each boat OK

//result polling function
if(isset($pollreturn)){
    $return=$pollreturn;
}

echo $return;
$conn->close();
?>


























