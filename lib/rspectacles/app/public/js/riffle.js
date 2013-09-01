(function (definition) {
    // AMD
    if (typeof define === "function") {
        define(definition);
    // CommonJS
    } else if (typeof exports === "object") {
        definition(this, exports);
    // Browser
    } else {
        definition(this);
    }
}(function (require, exports, module) {
    "use strict";
    var old,
        _;

    exports = exports || window;

    if (!window.setTimeout) {
        return;
    }

    function stream(userSuppliedStreamFn) {
        var chain = {};

        function defaultStreamFn(output) {
            var inputs = _.argumentsToArray(arguments);
            inputs.shift();
            if (inputs.length === 0) {
                window.setTimeout(function () {
                    output();
                }, 0);
            }
            _.each(inputs, function invokeOutput(input) {
                if (!_.isUndefined(input)) {
                    window.setTimeout(function delayedInvokeOutput() {
                        output(input);
                    }, 0);
                }
            });
        }

        (function () {
            var outputFns = [], streamFn;
            function outputAllFns() {
                var outputs = _.argumentsToArray(arguments);
                _.each(outputFns, function applyFunction(f) {
                    _.applyArgsToFn(f, outputs);
                });
            }
            streamFn = _.isFunction(userSuppliedStreamFn) ? userSuppliedStreamFn : defaultStreamFn;
            chain.invoke = function invoke() {
                var outputs = _.argumentsToArray(arguments);
                outputs.unshift(outputAllFns);
                _.applyArgsToFn(streamFn, outputs);
                return chain;
            };
            chain.onOutput = function onOutput(f) {
                if (!_.isFunction(f)) {
                    throw new Error('onOutput expecting callback function');
                }
                outputFns.push(f);
                return chain;
            };
            chain.offOutput = function offOutput(f) {
                if (!_.isFunction(f)) {
                    throw new Error('offOutput expecting callback function');
                }
                outputFns = _.reject(outputFns, function isSameAsReferenceInScope(x) {
                    return x === f;
                });
                return chain;
            };
        }());

        (function () {
            var callbacks = [],
                inputStreams = [];
            function wait(streams, idx) {
                var unbindStreams = inputStreams[idx];
                function invokeWithOneArg(x) {
                    var outputs = [];
                    outputs.length = idx + 1;
                    outputs[idx] = x;
                    chain.invoke.apply(window, _.isUndefined(x) ? [] : outputs);
                }
                if (unbindStreams) {
                    _.each(unbindStreams, function unbindInputs(s) {
                        s.offOutput(callbacks[idx]);
                    });
                    delete callbacks[idx];
                    delete inputStreams[idx];
                }
                _.each(streams, function registerOnOutput(stream) {
                    stream.onOutput(invokeWithOneArg);
                });
                callbacks[idx] = invokeWithOneArg;
                inputStreams[idx] = streams;
            }
            chain.input = function input() {
                var i, removeStreamIndexes = [];
                _.each(arguments, function bindInputs(inputs, inIdx) {
                    if (stream.isStream(inputs)) {
                        inputs = [inputs];
                    }
                    if (_.isArray(inputs)) {
                        inputs = _.reject(inputs, function isNotStream(obj) {
                            return !stream.isStream(obj);
                        });
                        wait(inputs, inIdx);
                    }
                });
                for (i = arguments.length; i < inputStreams.length; i += 1) {
                    removeStreamIndexes.push(i);
                }
                _.each(removeStreamIndexes, function (idx) {
                    _.each(inputStreams[idx], function (stream) { stream.offOutput(callbacks[idx]); });
                    delete callbacks[idx];
                    delete inputStreams[idx];
                });
                return chain;
            };
        }());
        return chain;
    }

    stream.isStream = function isStream(x) {
        return !!(x && x.invoke && x.onOutput && x.offOutput && x.input);
    };

    old = exports.stream;
    stream.noConflict = function noConflict() {
        exports.stream = old;
        return stream;
    };
    exports.stream = stream;

    _ = {
        breaker: {},
        arrayProto: Array.prototype,
        objProto: Object.prototype,
        isArray: Array.isArray || function isArray(obj) {
            return _.objProto.toString.call(obj) === '[object Array]';
        },
        isFunction: function isFunction(obj) {
            return _.objProto.toString.call(obj) === '[object Function]';
        },
        isUndefined: function isUndefined(obj) {
            return obj === void 0;
        },
        argumentsToArray: function argumentsToArray(args) {
            return _.arrayProto.slice.call(args);
        },
        applyArgsToFn: function applyArgsToFn(fn, args) {
            try {
                fn.apply(window, args);
            } catch (e) {
                if (console && console.exception) {
                    console.exception(e);
                }
            }
        },
        each: function each(obj, iterator, context) {
            var i, l, key;
            if (obj === null) {
                return;
            }
            if (_.arrayProto.forEach && obj.forEach === _.arrayProto.forEach) {
                obj.forEach(iterator, context);
            } else if (obj.length === +obj.length) {
                for (i = 0, l = obj.length; i < l; i += 1) {
                    if (obj.hasOwnProperty(i) && iterator.call(context, obj[i], i, obj) === _.breaker) {
                        return;
                    }
                }
            } else {
                for (key in obj) {
                    if (obj.hasOwnProperty(key)) {
                        if (iterator.call(context, obj[key], key, obj) === _.breaker) {
                            return;
                        }
                    }
                }
            }
        },
        reject: function reject(obj, iterator, context) {
            var results = [];
            if (obj === null) {
                return results;
            }
            _.each(obj, function exclude(value, index, list) {
                if (!iterator.call(context, value, index, list)) {
                    results[results.length] = value;
                }
            });
            return results;
        }
    };

}));
