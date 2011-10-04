// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

/**
 * @description Client interface to Nginx HTTP Push Module (NHPM) PubSub
 *  Data pushed from the Publisher is in JSON format with the following fields
 *  - String data
 *  - Boolean success
 *  - Boolean eot
 *  This format is defined in app/models/pub_sub.rb
 * @param String uri : consists of
 *   - protocol://domain[:port] obtained by the controller
 *   - path from constant matching same in nginx.conf
 *   - channel created on the fly by the controller
 *  for example:
 *    http://localhost:8000/push/publish?channel=20110930191815780
 * @param Function callback : function accepting three arguments matching the
 *   published JSON:
 *  - String message
 *  - Boolean error
 *  - Boolean eot
 * @param String last_modified :used internally
 * @param String etag :used internally
 */
 
function subscribe(uri, callback, last_modified, etag) {
    if (typeof last_modified == 'undefined') last_modified = 'Thu, 1 Jan 1970 00:00:00 GMT';
    if (typeof etag          == 'undefined') etag          = '0';
      
    $.ajax({
        beforeSend: function(xhr) {
            xhr.setRequestHeader('If-Modified-Since', last_modified);
            xhr.setRequestHeader('If-None-Match',     etag);
        },
        url:      uri,
        dataType: 'text',
        type:     'get',
        cache:    'false',
        success: function(json, status, xhr) {
            var data = jQuery.parseJSON(json);
            callback(data.message, data.error, data.eot);
            if (!data.eot) { // initiate another long poll
                etag          = xhr.getResponseHeader('Etag');
                last_modified = xhr.getResponseHeader('Last-Modified');
                subscribe(uri, callback, last_modified, etag);
            }
        },
        error: function(xhr, status, error) {
            var msg = 'ERROR: '+status+' : '+error;
            callback(msg, true, false);
        }
    });
};
