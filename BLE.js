var bleno = require('bleno');

var SERVICE_UUID = '77670a58-1cb4-4652-ae7d-2492776d303d';
var CHARACTERISTIC_UUID = '13092a53-7511-4ae0-8c9f-97c84cfb5d9a';

class CustomCharacteristic extends bleno.Characteristic {
    constructor() {
        super({
            uuid: CHARACTERISTIC_UUID,
            properties: ['read', 'write', 'notify'],
            value: null
        });

        this._value = Buffer.alloc(0);
    }

    onReadRequest(offset, callback) {
        console.log('Read request received');
        callback(this.RESULT_SUCCESS, this._value);
    }

    onWriteRequest(data, offset, withoutResponse, callback) {
        this._value = data;
        console.log('Write request received:', data.toString());
        callback(this.RESULT_SUCCESS);
    }

    onSubscribe(maxValueSize, updateValueCallback) {
        console.log('Device subscribed');
        this._updateValueCallback = updateValueCallback;
    }

    onUnsubscribe() {
        console.log('Device unsubscribed');
        this._updateValueCallback = null;
    }
}

var customService = new bleno.PrimaryService({
    uuid: SERVICE_UUID,
    characteristics: [new CustomCharacteristic()]
});

bleno.on('stateChange', function (state) {
    console.log(`State change: ${state}`);
    if (state === 'poweredOn') {
        bleno.startAdvertising('RaspberryPi', [SERVICE_UUID]);
    } else {
        bleno.stopAdvertising();
    }
});

bleno.on('advertisingStart', function (error) {
    console.log('Advertising start:', error ? `error ${error}` : 'success');
    if (!error) {
        bleno.setServices([customService]);
    }
});

bleno.on('advertisingStop', function() {
    console.log('Advertising stopped');
});
