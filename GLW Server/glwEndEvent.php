<?php header("content-type: text/plain; charset=utf-8"); ?>
<?php
$data       = file_get_contents("php://input");
//$cols       = explode(",",$data);
require '../../glwdb.php';

$idEvents=$data;

$sql = "DELETE FROM glwBoats WHERE idEvents=".$idEvents;
if ($conn->query($sql) === TRUE) {
    //print "OK";
} else {
    $conn->close();
    die("KOEndEvent Error1: " . $sql . "\n" . $conn->error);
}

$sql = "DELETE FROM glwVariations WHERE idEvents=".$idEvents;
if ($conn->query($sql) === TRUE) {
    //print "OK";
} else {
    $conn->close();
    die("KOEndEvent Error2: " . $sql . "\n" . $conn->error);
}

$sql = "DELETE FROM glwEventsMap WHERE idEvents=".$idEvents;
if ($conn->query($sql) === TRUE) {
    //print "OK";
} else {
    $conn->close();
    die("KOEndEvent Error3: " . $sql . "\n" . $conn->error);
}

$sql = "DELETE FROM glwModif WHERE idEvents=".$idEvents;
if ($conn->query($sql) === TRUE) {
    //print "OK";
} else {
    $conn->close();
    die("KOEndEvent Error3: " . $sql . "\n" . $conn->error);
}

$sql = "DELETE FROM glwEvents WHERE id=".$idEvents;
if ($conn->query($sql) === TRUE) {
    print "OK".$idEvents;
} else {
    $conn->close();
    die("KOEndEvent Error4: " . $sql . "\n" . $conn->error);
}
$conn->close();
?>