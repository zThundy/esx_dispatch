var resourceName = ""

const app = new Vue({
    el: "#app",
    data: {
        showing_list: false,
        dispatchList: [],
        cacheDispatch: [],
    },
    methods: {
        AddNewNotification(notification) {
            this.dispatchList.unshift(notification);
            this.cacheDispatch.unshift(notification);
            
            if (this.cacheDispatch.length > 30) {
                this.cacheDispatch.pop();
            }

            setTimeout(() => {
                // this.dispatchList.pop();
                $("#" + notification.id).removeClass("fade-left-enter")
                $("#" + notification.id).addClass("fade-right-leave")
                setTimeout(() => {
                    this.dispatchList.pop();
                }, 300)
            }, notification.duration);
        },
        SetGPSPosition(notification) {
            // console.log(JSON.stringify(notification))
            $.post('https://' + resourceName + '/setGPSPosition', JSON.stringify({
                position: notification.position
            }));
        },
        ClearAllDispatch() {
            if (this.cacheDispatch.length > 0) {
                $.post('https://' + resourceName + '/clearNotifications', JSON.stringify({
                    notifications: this.dispatchList
                }));

                this.cacheDispatch = [];
                this.dispatchList = [];
            }
        },
        DisableNotifications() {
            $.post('https://' + resourceName + '/disableNotifications', JSON.stringify({}));
        }
    },
    computed: {},
});

window.addEventListener('message', function(event) {
    // console.log(JSON.stringify(event.data))
    if (event.data.type == "addNewNotification") {
        /*
            message: 'this is a test dispatch',
            priority: rand,
            code: '10-5051',
            duration: 5000,
            title: 'This is a test title This is a test title This is a test title This is',
            officer: 'Giovanni Lucky',
            street: 'Sono una strada | lunga tre sezioni e anche di più | per vedere cosa succede',
            id: id
        */
        app.AddNewNotification(event.data.notification);
    };

    if (event.data.type == "showOldNotifications") {
        app.showing_list = event.data.show;
    };

    if (event.data.type == "sendResourceName") {
        resourceName = event.data.resource;
    };
});

// let id = 0
document.onkeydown = function(event) {
    // if (event.key === "Escape") {
    //     if (app.showing_list) {
    //         app.showing_list = false;
    //         $.post('https://' + resourceName + '/close', JSON.stringify({}));
    //     };
    // };

    // if (event.key == 1) {
    //     id += 1
    //     let rand = Math.random()
    //     if (rand < 0.5) 
    //         rand = 1
    //     else
    //         rand = 2
    //     app.AddNewNotification({
    //         message: 'this is a test message',
    //         priority: rand,
    //         code: '10-10',
    //         duration: 5000,
    //         title: 'This is a test title This is a test title This is a test title This is',
    //         officer: 'Giovanni Lucky',
    //         street: 'Sono una strada | lunga tre sezioni e anche di più | per vedere cosa succede',
    //         id: id
    //     })
    // }
    // if (event.key == 2) {
    //     app.showing_list = !app.showing_list;
    // }
};