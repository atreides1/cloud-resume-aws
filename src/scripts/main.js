visitorCount = 0;
const apiUrl = "https://kq4rdxywda.execute-api.us-west-2.amazonaws.com/default/getVisitorCount";

fetch(apiUrl)
  .then((response) => {
    if (!response.ok) {
      throw new Error("Network response was not ok");
    }
    return response.json();
  })
  .then((data) => {
    console.log(data);
    visitorCount = Number(data["visitorCount"]);
    console.log("total visitor count: ", visitorCount);

    // change number suffix (eg 1st 2nd 3rd 4th 5th 6th)
    let suffix = "th";
    switch (visitorCount % 10) {
      case 1:
        if (visitorCount != 11) {
          suffix = "st";
        }
        break;
      case 2:
        if (visitorCount != 12) {
          suffix = "nd";
        }
        break;
      case 3:
        if (visitorCount != 13) {
          suffix = "rd";
        }
        break;
      default:
        suffix = "th";
    }

    document.getElementById(
      "visitorCount"
    ).innerText = `Fun fact, you're the ${visitorCount}${suffix} visitor to this page`;
  })
  .catch((error) => {
    console.error("Error:", error);
  });



