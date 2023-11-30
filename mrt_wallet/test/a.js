; var bigRat = (function (bigInt) {
    "use strict";

    function BigRational(num, denom) {
        // Alias properties kept for backwards compatability
        if (denom.isZero()) throw "Denominator cannot be 0.";
        this.numerator = this.num = num;
        this.denominator = this.denom = denom;
    }

    var gcd = bigInt.gcd,
        lcm = bigInt.lcm;

    function reduce(n, d) {
        var divisor = gcd(n, d),
            num = n.over(divisor),
            denom = d.over(divisor);
        if (denom.isNegative()) {
            return new BigRational(num.negate(), denom.negate());
        }
        return new BigRational(num, denom);
    }

    BigRational.prototype.add = function (n, d) {
        var v = interpret(n, d),
            multiple = lcm(this.denom, v.denom),
            a = multiple.divide(this.denom),
            b = multiple.divide(v.denom);

        a = this.num.times(a);
        b = v.num.times(b);
        return reduce(a.add(b), multiple);
    };
    BigRational.prototype.plus = BigRational.prototype.add;

    BigRational.prototype.subtract = function (n, d) {
        var v = interpret(n, d);
        return this.add(v.negate());
    };
    BigRational.prototype.minus = BigRational.prototype.subtract;

    BigRational.prototype.multiply = function (n, d) {
        var v = interpret(n, d);
        return reduce(this.num.times(v.num), this.denom.times(v.denom));
    };
    BigRational.prototype.times = BigRational.prototype.multiply;

    BigRational.prototype.divide = function (n, d) {
        var v = interpret(n, d);
        return reduce(this.num.times(v.denom), this.denom.times(v.num));
    };
    BigRational.prototype.over = BigRational.prototype.divide;

    BigRational.prototype.reciprocate = function () {
        return new BigRational(this.denom, this.num);
    };
    BigRational.prototype.mod = function (n, d) {
        var v = interpret(n, d);
        return this.minus(v.times(this.over(v).floor()));
    };
    BigRational.prototype.pow = function (n) {
        var v = bigInt(n);
        var num = this.num.pow(v),
            denom = this.denom.pow(v);
        return reduce(num, denom);
    };

    BigRational.prototype.floor = function (toBigInt) {
        var divmod = this.num.divmod(this.denom),
            floor;
        if (divmod.remainder.isZero() || !divmod.quotient.isNegative()) {
            floor = divmod.quotient;
        }
        else floor = divmod.quotient.prev();
        if (toBigInt) return floor;
        return new BigRational(floor, bigInt[1]);
    };
    BigRational.prototype.ceil = function (toBigInt) {
        var divmod = this.num.divmod(this.denom),
            ceil;
        if (divmod.remainder.isZero() || divmod.quotient.isNegative()) {
            ceil = divmod.quotient;
        }
        else ceil = divmod.quotient.next();
        if (toBigInt) return ceil;
        return new BigRational(ceil, bigInt[1]);
    };
    BigRational.prototype.round = function (toBigInt) {
        return this.add(1, 2).floor(toBigInt);
    };

    BigRational.prototype.compareAbs = function (n, d) {
        var v = interpret(n, d);
        if (this.denom.equals(v.denom)) {
            return this.num.compareAbs(v.num);
        }
        return this.num.times(v.denom).compareAbs(v.num.times(this.denom));
    };
    BigRational.prototype.compare = function (n, d) {
        var v = interpret(n, d);
        if (this.denom.equals(v.denom)) {
            return this.num.compare(v.num);
        }
        var comparison = this.denom.isNegative() === v.denom.isNegative() ? 1 : -1;
        return comparison * this.num.times(v.denom).compare(v.num.times(this.denom));
    };
    BigRational.prototype.compareTo = BigRational.prototype.compare;

    BigRational.prototype.equals = function (n, d) {
        return this.compare(n, d) === 0;
    };
    BigRational.prototype.eq = BigRational.prototype.equals;

    BigRational.prototype.notEquals = function (n, d) {
        return this.compare(n, d) !== 0;
    };
    BigRational.prototype.neq = BigRational.prototype.notEquals;

    BigRational.prototype.lesser = function (n, d) {
        return this.compare(n, d) < 0;
    };
    BigRational.prototype.lt = BigRational.prototype.lesser;

    BigRational.prototype.lesserOrEquals = function (n, d) {
        return this.compare(n, d) <= 0;
    };
    BigRational.prototype.leq = BigRational.prototype.lesserOrEquals;

    BigRational.prototype.greater = function (n, d) {
        return this.compare(n, d) > 0;
    };
    BigRational.prototype.gt = BigRational.prototype.greater;

    BigRational.prototype.greaterOrEquals = function (n, d) {
        return this.compare(n, d) >= 0;
    };
    BigRational.prototype.geq = BigRational.prototype.greaterOrEquals;

    BigRational.prototype.abs = function () {
        if (this.isPositive()) return this;
        return this.negate();
    };
    BigRational.prototype.negate = function () {
        if (this.denom.isNegative()) {
            return new BigRational(this.num, this.denom.negate());
        }
        return new BigRational(this.num.negate(), this.denom);
    };
    BigRational.prototype.isNegative = function () {
        return this.num.isNegative() !== this.denom.isNegative() && !this.num.isZero();
    };
    BigRational.prototype.isPositive = function () {
        return this.num.isNegative() === this.denom.isNegative() && !this.num.isZero();
    };
    BigRational.prototype.isZero = function () {
        return this.num.isZero();
    };

    BigRational.prototype.toDecimal = function (digits) {
        digits = typeof digits === "number" ? digits : 10;
        var n = this.num.divmod(this.denom);
        var intPart = n.quotient.abs().toString();
        var remainder = parse(n.remainder.abs(), this.denom);
        var shiftedRemainder = remainder.times(bigInt("1e" + digits));
        var decPart = shiftedRemainder.num.over(shiftedRemainder.denom).toString();
        if (decPart.length < digits) {
            decPart = new Array(digits - decPart.length + 1).join("0") + decPart;
        }
        if (shiftedRemainder.num.mod(shiftedRemainder.denom).isZero()) {
            while (decPart.slice(-1) === "0") {
                decPart = decPart.slice(0, -1);
            }
        }
        if (digits < 1) decPart = "";
        if (this.isNegative()) {
            intPart = "-" + intPart;
        }
        if (decPart === "") {
            return intPart;
        }
        return intPart + "." + decPart;
    };

    BigRational.prototype.toString = function () {
        return String(this.num) + "/" + String(this.denom);
    };

    BigRational.prototype.valueOf = function () {
        if (!isFinite(+this.num) || !isFinite(+this.denom)) {
            return +this.toDecimal(64);
        }
        return this.num / this.denom;
    };

    function interpret(n, d) {
        return parse(n, d);
    }
    function parseDecimal(n) {
        var parts = n.split(/e/i);
        if (parts.length > 2) {
            throw new Error("Invalid input: too many 'e' tokens");
        }
        if (parts.length > 1) {
            var isPositive = true;
            if (parts[1][0] === "-") {
                parts[1] = parts[1].slice(1);
                isPositive = false;
            }
            if (parts[1][0] === "+") {
                parts[1] = parts[1].slice(1);
            }
            var significand = parseDecimal(parts[0]);
            var exponent = new BigRational(bigInt(10).pow(parts[1]), bigInt[1]);
            if (isPositive) {
                return significand.times(exponent);
            } else {
                return significand.over(exponent);
            }
        }
        parts = n.trim().split(".");
        if (parts.length > 2) {
            throw new Error("Invalid input: too many '.' tokens");
        }
        if (parts.length > 1) {
            var isNegative = parts[0][0] === '-';
            if (isNegative) parts[0] = parts[0].slice(1);
            var intPart = new BigRational(bigInt(parts[0]), bigInt[1]);
            var length = parts[1].length;
            while (parts[1][0] === "0") {
                parts[1] = parts[1].slice(1);
            }
            var exp = "1" + Array(length + 1).join("0");
            var decPart = reduce(bigInt(parts[1]), bigInt(exp));
            intPart = intPart.add(decPart);
            if (isNegative) intPart = intPart.negate();
            return intPart;
        }
        return new BigRational(bigInt(n), bigInt[1]);
    }
    function parse(a, b) {
        if (!a) {
            return new BigRational(bigInt(0), bigInt[1]);
        }
        if (b) {
            return reduce(bigInt(a), bigInt(b));
        }
        if (bigInt.isInstance(a)) {
            return new BigRational(a, bigInt[1]);
        }
        if (a instanceof BigRational) return a;

        var num;
        var denom;

        var text = String(a);
        var texts = text.split("/");
        if (texts.length > 2) {
            throw new Error("Invalid input: too many '/' tokens");
        }
        if (texts.length > 1) {
            var parts = texts[0].split("_");
            if (parts.length > 2) {
                throw new Error("Invalid input: too many '_' tokens");
            }
            if (parts.length > 1) {
                var isPositive = parts[0][0] !== "-";
                num = bigInt(parts[0]).times(texts[1]);
                if (isPositive) {
                    num = num.add(parts[1]);
                } else {
                    num = num.subtract(parts[1]);
                }
                denom = bigInt(texts[1]);
                return reduce(num, denom);
            }
            return reduce(bigInt(texts[0]), bigInt(texts[1]));
        }
        return parseDecimal(text);
    }

    parse.zero = parse(0);
    parse.one = parse(1);
    parse.minusOne = parse(-1);

    return parse;
})(typeof bigInt !== "undefined" ? bigInt : require("big-integer"));
if (typeof module !== "undefined") {
    if (module.hasOwnProperty("exports")) {
        module.exports = bigRat;
    }
}