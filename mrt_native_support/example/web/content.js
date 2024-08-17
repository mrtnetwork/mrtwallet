addEventListener("message",(s)=>{
    console.log("got data: ",s.data)
    if(s.data =="jafar"){
    chrome.storage.local.onChanged.addListener(function(obj) {
        console.log("read storage from content: ",obj);
    });
    
    chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
        console.log(message)
        sendResponse({id:"mohsen", message: "jb", type: "j3"})
    });

//         var port = chrome.runtime.connect({name:"content"});
// port.onMessage.addListener(function(message,sender){
//     console.log("message ",message)
//     port.postMessage({id: "ja", message: "jb", type: "j3"})
// });
    }
})