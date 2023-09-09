<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
//GLW Add new Event from Wind Setter

$headers    = apache_request_headers();
$objectgrid = $headers["X-SecondLife-Shard"];
$objectname = $headers["X-SecondLife-Object-Name"];
$objectkey  = $headers["X-SecondLife-Object-Key"];
$objectpos  = $headers["X-SecondLife-Local-Position"];
$ownerkey   = $headers["X-SecondLife-Owner-Key"];
$ownername  = $headers["X-SecondLife-Owner-Name"];
$regiondata = $headers["X-SecondLife-Region"];
$regiontmp  = explode ("(",$regiondata);        // cut cords off
$regionpos  = explode (")",$regiontmp[1]);
$regionpos  = explode (",",$regionpos[0]);
$regionname = substr($regiontmp[0],0,-1);       // cut last space from simname

$data       = file_get_contents("php://input");

require '../../glwdb.php';

$listBoats=array();
//select boats not updated in 24 hours
$sql = "SELECT id,UNIX_TIMESTAMP(updTime) as lastTime FROM glwBoats"; 
$result = $conn->query($sql);
if($result){
    $totalVars=$result->num_rows;
    if($totalVars>0){
        $limitTime=time()-86400; //24hours
        foreach($result as $field=>$value){
            if($limitTime>$value['lastTime']){
                $listBoats[]=$value['id'];
            }
        }
    }
}
$trashBoats = count($listBoats);
if($trashBoats>0){
    $idBoat=0;
    $sqldel="";
    foreach ($listBoats as $i => $value){
        $idBoat=$listBoats[$i];
        $sqldel="DELETE FROM glwBoats WHERE id=".$idBoat;
        $conn->query($sqldel);  //delete boats not updated in 24 hours           
    }
}

$listEvents=array();
//select events not updated in 24 hours
$sql="SELECT id,UNIX_TIMESTAMP(updTime) as lastTime FROM glwEvents"; 
$result=$conn->query($sql);
if($result){
    $totalVars=$result->num_rows;
    if($totalVars>0){
        $limitTime=time()-86400; //24hours
        foreach($result as $field=>$value){
            if($limitTime>$value['lastTime']){
                $listEvents[]=$value['id'];
            }
        }
    }
}
$trashEvents = count($listEvents);
if($trashEvents>0){
    $idEvent=0;
    $sqldel="";
    foreach ($listEvents as $i => $value){
        $idEvent=$listEvents[$i];
        $sqldel="SELECT id,UNIX_TIMESTAMP(updTime) as lastTime FROM glwBoats WHERE idEvents=".$idEvent;
        $result=$conn->query($sqldel); 
        if($result){
            $totalVars=$result->num_rows;
            if($totalVars>0){            
                //se ha encontrado un barco activo en el evento caducado. De momento no hacemos nada
            }else{
                $sqldel="DELETE FROM glwModif WHERE idEvents=".$idEvent;
                $conn->query($sqldel);
                $sqldel="DELETE FROM glwVariations WHERE idEvents=".$idEvent;
                $conn->query($sqldel);
                $sqldel="DELETE FROM glwEventsMap WHERE idEvents=".$idEvent;
                $conn->query($sqldel);
                $sqldel="DELETE FROM glwEvents WHERE id=".$idEvent;
                $conn->query($sqldel);
            }
        }
    }
}
?>


























