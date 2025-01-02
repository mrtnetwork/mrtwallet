(function dartProgram(){function copyProperties(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
b[q]=a[q]}}function mixinPropertiesHard(a,b){var s=Object.keys(a)
for(var r=0;r<s.length;r++){var q=s[r]
if(!b.hasOwnProperty(q)){b[q]=a[q]}}}function mixinPropertiesEasy(a,b){Object.assign(b,a)}var z=function(){var s=function(){}
s.prototype={p:{}}
var r=new s()
if(!(Object.getPrototypeOf(r)&&Object.getPrototypeOf(r).p===s.prototype.p))return false
try{if(typeof navigator!="undefined"&&typeof navigator.userAgent=="string"&&navigator.userAgent.indexOf("Chrome/")>=0)return true
if(typeof version=="function"&&version.length==0){var q=version()
if(/^\d+\.\d+\.\d+\.\d+$/.test(q))return true}}catch(p){}return false}()
function inherit(a,b){a.prototype.constructor=a
a.prototype["$i"+a.name]=a
if(b!=null){if(z){Object.setPrototypeOf(a.prototype,b.prototype)
return}var s=Object.create(b.prototype)
copyProperties(a.prototype,s)
a.prototype=s}}function inheritMany(a,b){for(var s=0;s<b.length;s++){inherit(b[s],a)}}function mixinEasy(a,b){mixinPropertiesEasy(b.prototype,a.prototype)
a.prototype.constructor=a}function mixinHard(a,b){mixinPropertiesHard(b.prototype,a.prototype)
a.prototype.constructor=a}function lazy(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){a[b]=d()}a[c]=function(){return this[b]}
return a[b]}}function lazyFinal(a,b,c,d){var s=a
a[b]=s
a[c]=function(){if(a[b]===s){var r=d()
if(a[b]!==s){A.c3(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a){a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.hl(b)
return new s(c,this)}:function(){if(s===null)s=A.hl(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.hl(a).prototype
return s}}var x=0
function tearOffParameters(a,b,c,d,e,f,g,h,i,j){if(typeof h=="number"){h+=x}return{co:a,iS:b,iI:c,rC:d,dV:e,cs:f,fs:g,fT:h,aI:i||0,nDA:j}}function installStaticTearOff(a,b,c,d,e,f,g,h){var s=tearOffParameters(a,true,false,c,d,e,f,g,h,false)
var r=staticTearOffGetter(s)
a[b]=r}function installInstanceTearOff(a,b,c,d,e,f,g,h,i,j){c=!!c
var s=tearOffParameters(a,false,c,d,e,f,g,h,i,!!j)
var r=instanceTearOffGetter(c,s)
a[b]=r}function setOrUpdateInterceptorsByTag(a){var s=v.interceptorsByTag
if(!s){v.interceptorsByTag=a
return}copyProperties(a,s)}function setOrUpdateLeafTags(a){var s=v.leafTags
if(!s){v.leafTags=a
return}copyProperties(a,s)}function updateTypes(a){var s=v.types
var r=s.length
s.push.apply(s,a)
return r}function updateHolder(a,b){copyProperties(b,a)
return a}var hunkHelpers=function(){var s=function(a,b,c,d,e){return function(f,g,h,i){return installInstanceTearOff(f,g,a,b,c,d,[h],i,e,false)}},r=function(a,b,c,d){return function(e,f,g,h){return installStaticTearOff(e,f,a,b,c,[g],h,d)}}
return{inherit:inherit,inheritMany:inheritMany,mixin:mixinEasy,mixinHard:mixinHard,installStaticTearOff:installStaticTearOff,installInstanceTearOff:installInstanceTearOff,_instance_0u:s(0,0,null,["$0"],0),_instance_1u:s(0,1,null,["$1"],0),_instance_2u:s(0,2,null,["$2"],0),_instance_0i:s(1,0,null,["$0"],0),_instance_1i:s(1,1,null,["$1"],0),_instance_2i:s(1,2,null,["$2"],0),_static_0:r(0,null,["$0"],0),_static_1:r(1,null,["$1"],0),_static_2:r(2,null,["$2"],0),makeConstList:makeConstList,lazy:lazy,lazyFinal:lazyFinal,updateHolder:updateHolder,convertToFastObject:convertToFastObject,updateTypes:updateTypes,setOrUpdateInterceptorsByTag:setOrUpdateInterceptorsByTag,setOrUpdateLeafTags:setOrUpdateLeafTags}}()
function initializeDeferredHunk(a){x=v.types.length
a(hunkHelpers,v,w,$)}var J={
hp(a,b,c,d){return{i:a,p:b,e:c,x:d}},
fE(a){var s,r,q,p,o,n=a[v.dispatchPropertyName]
if(n==null)if($.hm==null){A.lm()
n=a[v.dispatchPropertyName]}if(n!=null){s=n.p
if(!1===s)return n.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return n.i
if(n.e===r)throw A.b(A.i6("Return interceptor for "+A.z(s(a,n))))}q=a.constructor
if(q==null)p=null
else{o=$.fl
if(o==null)o=$.fl=v.getIsolateTag("_$dart_js")
p=q[o]}if(p!=null)return p
p=A.ls(a)
if(p!=null)return p
if(typeof a=="function")return B.W
s=Object.getPrototypeOf(a)
if(s==null)return B.H
if(s===Object.prototype)return B.H
if(typeof q=="function"){o=$.fl
if(o==null)o=$.fl=v.getIsolateTag("_$dart_js")
Object.defineProperty(q,o,{value:B.z,enumerable:false,writable:true,configurable:true})
return B.z}return B.z},
jp(a,b){if(a<0||a>4294967295)throw A.b(A.ax(a,0,4294967295,"length",null))
return J.jq(new Array(a),b)},
hG(a,b){if(a<0)throw A.b(A.a9("Length must be a non-negative integer: "+a,null))
return A.d(new Array(a),b.h("m<0>"))},
jq(a,b){var s=A.d(a,b.h("m<0>"))
s.$flags=1
return s},
aE(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.bh.prototype
return J.ck.prototype}if(typeof a=="string")return J.aW.prototype
if(a==null)return J.bi.prototype
if(typeof a=="boolean")return J.cj.prototype
if(Array.isArray(a))return J.m.prototype
if(typeof a!="object"){if(typeof a=="function")return J.L.prototype
if(typeof a=="symbol")return J.aZ.prototype
if(typeof a=="bigint")return J.aY.prototype
return a}if(a instanceof A.c)return a
return J.fE(a)},
fD(a){if(typeof a=="string")return J.aW.prototype
if(a==null)return a
if(Array.isArray(a))return J.m.prototype
if(typeof a!="object"){if(typeof a=="function")return J.L.prototype
if(typeof a=="symbol")return J.aZ.prototype
if(typeof a=="bigint")return J.aY.prototype
return a}if(a instanceof A.c)return a
return J.fE(a)},
aS(a){if(a==null)return a
if(Array.isArray(a))return J.m.prototype
if(typeof a!="object"){if(typeof a=="function")return J.L.prototype
if(typeof a=="symbol")return J.aZ.prototype
if(typeof a=="bigint")return J.aY.prototype
return a}if(a instanceof A.c)return a
return J.fE(a)},
lh(a){if(a==null)return a
if(typeof a!="object"){if(typeof a=="function")return J.L.prototype
if(typeof a=="symbol")return J.aZ.prototype
if(typeof a=="bigint")return J.aY.prototype
return a}if(a instanceof A.c)return a
return J.fE(a)},
fP(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.aE(a).U(a,b)},
j6(a,b){if(typeof b==="number")if(Array.isArray(a)||A.lq(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.aS(a).j(a,b)},
j7(a,b,c){return J.lh(a).bu(a,b,c)},
Z(a,b){return J.aS(a).aA(a,b)},
j8(a,b){return J.aS(a).by(a,b)},
hu(a,b){return J.aS(a).F(a,b)},
fQ(a){return J.aE(a).gq(a)},
ba(a){return J.aS(a).gA(a)},
c5(a){return J.fD(a).gm(a)},
j9(a){return J.aE(a).gv(a)},
ja(a){return J.aE(a).gB(a)},
c6(a,b,c){return J.aS(a).a4(a,b,c)},
bb(a){return J.aE(a).i(a)},
ci:function ci(){},
cj:function cj(){},
bi:function bi(){},
bl:function bl(){},
av:function av(){},
cB:function cB(){},
bx:function bx(){},
L:function L(){},
aY:function aY(){},
aZ:function aZ(){},
m:function m(a){this.$ti=a},
dA:function dA(a){this.$ti=a},
bc:function bc(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
bj:function bj(){},
bh:function bh(){},
ck:function ck(){},
aW:function aW(){}},A={fX:function fX(){},
hA(a,b,c){if(b.h("k<0>").b(a))return new A.bE(a,b.h("@<0>").l(c).h("bE<1,2>"))
return new A.aI(a,b.h("@<0>").l(c).h("aI<1,2>"))},
i3(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
jV(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
fz(a,b,c){return a},
hn(a){var s,r
for(s=$.Y.length,r=0;r<s;++r)if(a===$.Y[r])return!0
return!1},
jA(a,b,c,d){if(t.V.b(a))return new A.bf(a,b,c.h("@<0>").l(d).h("bf<1,2>"))
return new A.aM(a,b,c.h("@<0>").l(d).h("aM<1,2>"))},
jn(){return new A.b3("No element")},
az:function az(){},
be:function be(a,b){this.a=a
this.$ti=b},
aI:function aI(a,b){this.a=a
this.$ti=b},
bE:function bE(a,b){this.a=a
this.$ti=b},
bC:function bC(){},
K:function K(a,b){this.a=a
this.$ti=b},
aJ:function aJ(a,b){this.a=a
this.$ti=b},
da:function da(a,b){this.a=a
this.b=b},
b_:function b_(a){this.a=a},
dV:function dV(){},
k:function k(){},
w:function w(){},
aL:function aL(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aM:function aM(a,b,c){this.a=a
this.b=b
this.$ti=c},
bf:function bf(a,b,c){this.a=a
this.b=b
this.$ti=c},
bn:function bn(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
y:function y(a,b,c){this.a=a
this.b=b
this.$ti=c},
P:function P(){},
ay:function ay(a,b){this.a=a
this.$ti=b},
bT:function bT(){},
iQ(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
lq(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.da.b(a)},
z(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.bb(a)
return s},
cC(a){var s,r=$.hQ
if(r==null)r=$.hQ=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
dQ(a){return A.jE(a)},
jE(a){var s,r,q,p
if(a instanceof A.c)return A.U(A.aT(a),null)
s=J.aE(a)
if(s===B.S||s===B.X||t.cr.b(a)){r=B.C(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.U(A.aT(a),null)},
jN(a){if(typeof a=="number"||A.fv(a))return J.bb(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.ap)return a.i(0)
return"Instance of '"+A.dQ(a)+"'"},
hP(a){var s,r,q,p,o=a.length
if(o<=500)return String.fromCharCode.apply(null,a)
for(s="",r=0;r<o;r=q){q=r+500
p=q<o?q:o
s+=String.fromCharCode.apply(null,a.slice(r,p))}return s},
jP(a){var s,r,q,p=A.d([],t.t)
for(s=a.length,r=0;r<a.length;a.length===s||(0,A.hq)(a),++r){q=a[r]
if(!A.fw(q))throw A.b(A.c0(q))
if(q<=65535)B.a.k(p,q)
else if(q<=1114111){B.a.k(p,55296+(B.b.af(q-65536,10)&1023))
B.a.k(p,56320+(q&1023))}else throw A.b(A.c0(q))}return A.hP(p)},
jO(a){var s,r,q
for(s=a.length,r=0;r<s;++r){q=a[r]
if(!A.fw(q))throw A.b(A.c0(q))
if(q<0)throw A.b(A.c0(q))
if(q>65535)return A.jP(a)}return A.hP(a)},
b1(a){if(a.date===void 0)a.date=new Date(a.a)
return a.date},
jM(a){var s=A.b1(a).getUTCFullYear()+0
return s},
jK(a){var s=A.b1(a).getUTCMonth()+1
return s},
jG(a){var s=A.b1(a).getUTCDate()+0
return s},
jH(a){var s=A.b1(a).getUTCHours()+0
return s},
jJ(a){var s=A.b1(a).getUTCMinutes()+0
return s},
jL(a){var s=A.b1(a).getUTCSeconds()+0
return s},
jI(a){var s=A.b1(a).getUTCMilliseconds()+0
return s},
jF(a){var s=a.$thrownJsError
if(s==null)return null
return A.aF(s)},
hR(a,b){var s
if(a.$thrownJsError==null){s=A.b(a)
a.$thrownJsError=s
s.stack=b.i(0)}},
e(a,b){if(a==null)J.c5(a)
throw A.b(A.fB(a,b))},
fB(a,b){var s,r="index"
if(!A.fw(b))return new A.a4(!0,b,r,null)
s=J.c5(a)
if(b<0||b>=s)return A.hE(b,s,a,r)
return new A.b2(null,null,!0,b,r,"Value not in range")},
c0(a){return new A.a4(!0,a,null,null)},
b(a){return A.iM(new Error(),a)},
iM(a,b){var s
if(b==null)b=new A.ah()
a.dartException=b
s=A.ly
if("defineProperty" in Object){Object.defineProperty(a,"message",{get:s})
a.name=""}else a.toString=s
return a},
ly(){return J.bb(this.dartException)},
a7(a){throw A.b(a)},
iP(a,b){throw A.iM(b,a)},
I(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.iP(A.kE(a,b,c),s)},
kE(a,b,c){var s,r,q,p,o,n,m,l,k
if(typeof b=="string")s=b
else{r="[]=;add;removeWhere;retainWhere;removeRange;setRange;setInt8;setInt16;setInt32;setUint8;setUint16;setUint32;setFloat32;setFloat64".split(";")
q=r.length
p=b
if(p>q){c=p/q|0
p%=q}s=r[p]}o=typeof c=="string"?c:"modify;remove from;add to".split(";")[c]
n=t.j.b(a)?"list":"ByteData"
m=a.$flags|0
l="a "
if((m&4)!==0)k="constant "
else if((m&2)!==0){k="unmodifiable "
l="an "}else k=(m&1)!==0?"fixed-length ":""
return new A.by("'"+s+"': Cannot "+o+" "+l+k+n)},
hq(a){throw A.b(A.aq(a))},
ai(a){var s,r,q,p,o,n
a=A.lw(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.d([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.eI(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
eJ(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
i5(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
fY(a,b){var s=b==null,r=s?null:b.method
return new A.cn(a,r,s?null:b.receiver)},
aH(a){var s
if(a==null)return new A.dO(a)
if(a instanceof A.bg){s=a.a
return A.aG(a,s==null?t.K.a(s):s)}if(typeof a!=="object")return a
if("dartException" in a)return A.aG(a,a.dartException)
return A.l8(a)},
aG(a,b){if(t.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
l8(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.b.af(r,16)&8191)===10)switch(q){case 438:return A.aG(a,A.fY(A.z(s)+" (Error "+q+")",null))
case 445:case 5007:A.z(s)
return A.aG(a,new A.bu())}}if(a instanceof TypeError){p=$.iV()
o=$.iW()
n=$.iX()
m=$.iY()
l=$.j0()
k=$.j1()
j=$.j_()
$.iZ()
i=$.j3()
h=$.j2()
g=p.I(s)
if(g!=null)return A.aG(a,A.fY(A.f(s),g))
else{g=o.I(s)
if(g!=null){g.method="call"
return A.aG(a,A.fY(A.f(s),g))}else if(n.I(s)!=null||m.I(s)!=null||l.I(s)!=null||k.I(s)!=null||j.I(s)!=null||m.I(s)!=null||i.I(s)!=null||h.I(s)!=null){A.f(s)
return A.aG(a,new A.bu())}}return A.aG(a,new A.cQ(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.bv()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.aG(a,new A.a4(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.bv()
return a},
aF(a){var s
if(a instanceof A.bg)return a.b
if(a==null)return new A.bN(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.bN(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
d8(a){if(a==null)return J.fQ(a)
if(typeof a=="object")return A.cC(a)
return J.fQ(a)},
lg(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.t(0,a[s],a[r])}return b},
kO(a,b,c,d,e,f){t.Z.a(a)
switch(A.X(b)){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.b(new A.f7("Unsupported number of arguments for wrapped closure"))},
c1(a,b){var s=a.$identity
if(!!s)return s
s=A.ld(a,b)
a.$identity=s
return s},
ld(a,b){var s
switch(b){case 0:s=a.$0
break
case 1:s=a.$1
break
case 2:s=a.$2
break
case 3:s=a.$3
break
case 4:s=a.$4
break
default:s=null}if(s!=null)return s.bind(a)
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.kO)},
ji(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.cH().constructor.prototype):Object.create(new A.aU(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.hB(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.je(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.hB(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
je(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.b("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.jc)}throw A.b("Error in functionType of tearoff")},
jf(a,b,c,d){var s=A.hz
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
hB(a,b,c,d){if(c)return A.jh(a,b,d)
return A.jf(b.length,d,a,b)},
jg(a,b,c,d){var s=A.hz,r=A.jd
switch(b?-1:a){case 0:throw A.b(new A.cE("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
jh(a,b,c){var s,r
if($.hx==null)$.hx=A.hw("interceptor")
if($.hy==null)$.hy=A.hw("receiver")
s=b.length
r=A.jg(s,c,a,b)
return r},
hl(a){return A.ji(a)},
jc(a,b){return A.fr(v.typeUniverse,A.aT(a.a),b)},
hz(a){return a.a},
jd(a){return a.b},
hw(a){var s,r,q,p=new A.aU("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.b(A.a9("Field name "+a+" not found.",null))},
iJ(a){if(a==null)A.l9("boolean expression must not be null")
return a},
l9(a){throw A.b(new A.cT(a))},
m8(a){throw A.b(new A.cY(a))},
li(a){return v.getIsolateTag(a)},
le(a){var s,r=A.d([],t.s)
if(a==null)return r
if(Array.isArray(a)){for(s=0;s<a.length;++s)r.push(String(a[s]))
return r}r.push(String(a))
return r},
m7(a,b,c){Object.defineProperty(a,b,{value:c,enumerable:false,writable:true,configurable:true})},
ls(a){var s,r,q,p,o,n=A.f($.iL.$1(a)),m=$.fC[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.fI[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=A.T($.iH.$2(a,n))
if(q!=null){m=$.fC[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.fI[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.fL(s)
$.fC[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.fI[n]=s
return s}if(p==="-"){o=A.fL(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.iN(a,s)
if(p==="*")throw A.b(A.i6(n))
if(v.leafTags[n]===true){o=A.fL(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.iN(a,s)},
iN(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.hp(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
fL(a){return J.hp(a,!1,null,!!a.$iV)},
lu(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.fL(s)
else return J.hp(s,c,null,null)},
lm(){if(!0===$.hm)return
$.hm=!0
A.ln()},
ln(){var s,r,q,p,o,n,m,l
$.fC=Object.create(null)
$.fI=Object.create(null)
A.ll()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.iO.$1(o)
if(n!=null){m=A.lu(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
ll(){var s,r,q,p,o,n,m=B.L()
m=A.b8(B.M,A.b8(B.N,A.b8(B.D,A.b8(B.D,A.b8(B.O,A.b8(B.P,A.b8(B.Q(B.C),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.iL=new A.fF(p)
$.iH=new A.fG(o)
$.iO=new A.fH(n)},
b8(a,b){return a(b)||b},
lf(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
jt(a,b,c,d,e,f){var s=function(g,h){try{return new RegExp(g,h)}catch(r){return r}}(a,""+"i"+""+""+"")
if(s instanceof RegExp)return s
throw A.b(A.hD("Illegal RegExp pattern ("+String(s)+")",a))},
lw(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
eI:function eI(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
bu:function bu(){},
cn:function cn(a,b,c){this.a=a
this.b=b
this.c=c},
cQ:function cQ(a){this.a=a},
dO:function dO(a){this.a=a},
bg:function bg(a,b){this.a=a
this.b=b},
bN:function bN(a){this.a=a
this.b=null},
ap:function ap(){},
c9:function c9(){},
ca:function ca(){},
cK:function cK(){},
cH:function cH(){},
aU:function aU(a,b){this.a=a
this.b=b},
cY:function cY(a){this.a=a},
cE:function cE(a){this.a=a},
cT:function cT(a){this.a=a},
ag:function ag(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
dJ:function dJ(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
W:function W(a,b){this.a=a
this.$ti=b},
bm:function bm(a,b,c){var _=this
_.a=a
_.b=b
_.d=_.c=null
_.$ti=c},
fF:function fF(a){this.a=a},
fG:function fG(a){this.a=a},
fH:function fH(a){this.a=a},
cm:function cm(a,b){this.a=a
this.b=b},
fm:function fm(a){this.b=a},
c3(a){A.iP(new A.b_("Field '"+a+"' has been assigned during initialization."),new Error())},
cX(a){var s=new A.f5(a)
return s.b=s},
f5:function f5(a){this.a=a
this.b=null},
kD(a){return a},
jB(a,b,c){var s=new Uint8Array(a,b,c)
return s},
aP(a,b,c){if(a>>>0!==a||a>=c)throw A.b(A.fB(b,a))},
bo:function bo(){},
bs:function bs(){},
d4:function d4(a){this.a=a},
bp:function bp(){},
b0:function b0(){},
bq:function bq(){},
br:function br(){},
co:function co(){},
cp:function cp(){},
cq:function cq(){},
cr:function cr(){},
cs:function cs(){},
ct:function ct(){},
cu:function cu(){},
bt:function bt(){},
cv:function cv(){},
bJ:function bJ(){},
bK:function bK(){},
bL:function bL(){},
bM:function bM(){},
hU(a,b){var s=b.c
return s==null?b.c=A.hg(a,b.x,!0):s},
h1(a,b){var s=b.c
return s==null?b.c=A.bQ(a,"ar",[b.x]):s},
hV(a){var s=a.w
if(s===6||s===7||s===8)return A.hV(a.x)
return s===12||s===13},
jU(a){return a.as},
aR(a){return A.d3(v.typeUniverse,a,!1)},
aC(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.aC(a1,s,a3,a4)
if(r===s)return a2
return A.it(a1,r,!0)
case 7:s=a2.x
r=A.aC(a1,s,a3,a4)
if(r===s)return a2
return A.hg(a1,r,!0)
case 8:s=a2.x
r=A.aC(a1,s,a3,a4)
if(r===s)return a2
return A.ir(a1,r,!0)
case 9:q=a2.y
p=A.b7(a1,q,a3,a4)
if(p===q)return a2
return A.bQ(a1,a2.x,p)
case 10:o=a2.x
n=A.aC(a1,o,a3,a4)
m=a2.y
l=A.b7(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.he(a1,n,l)
case 11:k=a2.x
j=a2.y
i=A.b7(a1,j,a3,a4)
if(i===j)return a2
return A.is(a1,k,i)
case 12:h=a2.x
g=A.aC(a1,h,a3,a4)
f=a2.y
e=A.l5(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.iq(a1,g,e)
case 13:d=a2.y
a4+=d.length
c=A.b7(a1,d,a3,a4)
o=a2.x
n=A.aC(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.hf(a1,n,c,!0)
case 14:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.b(A.c7("Attempted to substitute unexpected RTI kind "+a0))}},
b7(a,b,c,d){var s,r,q,p,o=b.length,n=A.fs(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.aC(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
l6(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.fs(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.aC(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
l5(a,b,c,d){var s,r=b.a,q=A.b7(a,r,c,d),p=b.b,o=A.b7(a,p,c,d),n=b.c,m=A.l6(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.d_()
s.a=q
s.b=o
s.c=m
return s},
d(a,b){a[v.arrayRti]=b
return a},
iK(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.lk(s)
return a.$S()}return null},
lo(a,b){var s
if(A.hV(b))if(a instanceof A.ap){s=A.iK(a)
if(s!=null)return s}return A.aT(a)},
aT(a){if(a instanceof A.c)return A.H(a)
if(Array.isArray(a))return A.F(a)
return A.hi(J.aE(a))},
F(a){var s=a[v.arrayRti],r=t.o
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
H(a){var s=a.$ti
return s!=null?s:A.hi(a)},
hi(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.kL(a,s)},
kL(a,b){var s=a instanceof A.ap?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.ks(v.typeUniverse,s.name)
b.$ccache=r
return r},
lk(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.d3(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
lj(a){return A.aQ(A.H(a))},
l4(a){var s=a instanceof A.ap?A.iK(a):null
if(s!=null)return s
if(t.bW.b(a))return J.j9(a).a
if(Array.isArray(a))return A.F(a)
return A.aT(a)},
aQ(a){var s=a.r
return s==null?a.r=A.iw(a):s},
iw(a){var s,r,q=a.as,p=q.replace(/\*/g,"")
if(p===q)return a.r=new A.fq(a)
s=A.d3(v.typeUniverse,p,!0)
r=s.r
return r==null?s.r=A.iw(s):r},
a8(a){return A.aQ(A.d3(v.typeUniverse,a,!1))},
kK(a){var s,r,q,p,o,n,m=this
if(m===t.K)return A.al(m,a,A.kT)
if(!A.an(m))s=m===t._
else s=!0
if(s)return A.al(m,a,A.kX)
s=m.w
if(s===7)return A.al(m,a,A.kI)
if(s===1)return A.al(m,a,A.iA)
r=s===6?m.x:m
q=r.w
if(q===8)return A.al(m,a,A.kP)
if(r===t.S)p=A.fw
else if(r===t.i||r===t.p)p=A.kS
else if(r===t.N)p=A.kV
else p=r===t.y?A.fv:null
if(p!=null)return A.al(m,a,p)
if(q===9){o=r.x
if(r.y.every(A.lp)){m.f="$i"+o
if(o==="n")return A.al(m,a,A.kR)
return A.al(m,a,A.kW)}}else if(q===11){n=A.lf(r.x,r.y)
return A.al(m,a,n==null?A.iA:n)}return A.al(m,a,A.kG)},
al(a,b,c){a.b=c
return a.b(b)},
kJ(a){var s,r=this,q=A.kF
if(!A.an(r))s=r===t._
else s=!0
if(s)q=A.kx
else if(r===t.K)q=A.kw
else{s=A.c2(r)
if(s)q=A.kH}r.a=q
return r.a(a)},
d7(a){var s=a.w,r=!0
if(!A.an(a))if(!(a===t._))if(!(a===t.L))if(s!==7)if(!(s===6&&A.d7(a.x)))r=s===8&&A.d7(a.x)||a===t.P||a===t.T
return r},
kG(a){var s=this
if(a==null)return A.d7(s)
return A.lr(v.typeUniverse,A.lo(a,s),s)},
kI(a){if(a==null)return!0
return this.x.b(a)},
kW(a){var s,r=this
if(a==null)return A.d7(r)
s=r.f
if(a instanceof A.c)return!!a[s]
return!!J.aE(a)[s]},
kR(a){var s,r=this
if(a==null)return A.d7(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.c)return!!a[s]
return!!J.aE(a)[s]},
kF(a){var s=this
if(a==null){if(A.c2(s))return a}else if(s.b(a))return a
A.ix(a,s)},
kH(a){var s=this
if(a==null)return a
else if(s.b(a))return a
A.ix(a,s)},
ix(a,b){throw A.b(A.ki(A.ii(a,A.U(b,null))))},
ii(a,b){return A.ce(a)+": type '"+A.U(A.l4(a),null)+"' is not a subtype of type '"+b+"'"},
ki(a){return new A.bO("TypeError: "+a)},
Q(a,b){return new A.bO("TypeError: "+A.ii(a,b))},
kP(a){var s=this,r=s.w===6?s.x:s
return r.x.b(a)||A.h1(v.typeUniverse,r).b(a)},
kT(a){return a!=null},
kw(a){if(a!=null)return a
throw A.b(A.Q(a,"Object"))},
kX(a){return!0},
kx(a){return a},
iA(a){return!1},
fv(a){return!0===a||!1===a},
ku(a){if(!0===a)return!0
if(!1===a)return!1
throw A.b(A.Q(a,"bool"))},
lY(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.b(A.Q(a,"bool"))},
lX(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.b(A.Q(a,"bool?"))},
lZ(a){if(typeof a=="number")return a
throw A.b(A.Q(a,"double"))},
m0(a){if(typeof a=="number")return a
if(a==null)return a
throw A.b(A.Q(a,"double"))},
m_(a){if(typeof a=="number")return a
if(a==null)return a
throw A.b(A.Q(a,"double?"))},
fw(a){return typeof a=="number"&&Math.floor(a)===a},
X(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.b(A.Q(a,"int"))},
m2(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.b(A.Q(a,"int"))},
m1(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.b(A.Q(a,"int?"))},
kS(a){return typeof a=="number"},
m3(a){if(typeof a=="number")return a
throw A.b(A.Q(a,"num"))},
m4(a){if(typeof a=="number")return a
if(a==null)return a
throw A.b(A.Q(a,"num"))},
kv(a){if(typeof a=="number")return a
if(a==null)return a
throw A.b(A.Q(a,"num?"))},
kV(a){return typeof a=="string"},
f(a){if(typeof a=="string")return a
throw A.b(A.Q(a,"String"))},
m5(a){if(typeof a=="string")return a
if(a==null)return a
throw A.b(A.Q(a,"String"))},
T(a){if(typeof a=="string")return a
if(a==null)return a
throw A.b(A.Q(a,"String?"))},
iF(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.U(a[q],b)
return s},
l_(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.iF(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.U(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
iy(a4,a5,a6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=", ",a3=null
if(a6!=null){s=a6.length
if(a5==null)a5=A.d([],t.s)
else a3=a5.length
r=a5.length
for(q=s;q>0;--q)B.a.k(a5,"T"+(r+q))
for(p=t.X,o=t._,n="<",m="",q=0;q<s;++q,m=a2){l=a5.length
k=l-1-q
if(!(k>=0))return A.e(a5,k)
n=n+m+a5[k]
j=a6[q]
i=j.w
if(!(i===2||i===3||i===4||i===5||j===p))l=j===o
else l=!0
if(!l)n+=" extends "+A.U(j,a5)}n+=">"}else n=""
p=a4.x
h=a4.y
g=h.a
f=g.length
e=h.b
d=e.length
c=h.c
b=c.length
a=A.U(p,a5)
for(a0="",a1="",q=0;q<f;++q,a1=a2)a0+=a1+A.U(g[q],a5)
if(d>0){a0+=a1+"["
for(a1="",q=0;q<d;++q,a1=a2)a0+=a1+A.U(e[q],a5)
a0+="]"}if(b>0){a0+=a1+"{"
for(a1="",q=0;q<b;q+=3,a1=a2){a0+=a1
if(c[q+1])a0+="required "
a0+=A.U(c[q+2],a5)+" "+c[q]}a0+="}"}if(a3!=null){a5.toString
a5.length=a3}return n+"("+a0+") => "+a},
U(a,b){var s,r,q,p,o,n,m,l=a.w
if(l===5)return"erased"
if(l===2)return"dynamic"
if(l===3)return"void"
if(l===1)return"Never"
if(l===4)return"any"
if(l===6)return A.U(a.x,b)
if(l===7){s=a.x
r=A.U(s,b)
q=s.w
return(q===12||q===13?"("+r+")":r)+"?"}if(l===8)return"FutureOr<"+A.U(a.x,b)+">"
if(l===9){p=A.l7(a.x)
o=a.y
return o.length>0?p+("<"+A.iF(o,b)+">"):p}if(l===11)return A.l_(a,b)
if(l===12)return A.iy(a,b,null)
if(l===13)return A.iy(a.x,b,a.y)
if(l===14){n=a.x
m=b.length
n=m-1-n
if(!(n>=0&&n<m))return A.e(b,n)
return b[n]}return"?"},
l7(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
kt(a,b){var s=a.tR[b]
for(;typeof s=="string";)s=a.tR[s]
return s},
ks(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.d3(a,b,!1)
else if(typeof m=="number"){s=m
r=A.bR(a,5,"#")
q=A.fs(s)
for(p=0;p<s;++p)q[p]=r
o=A.bQ(a,b,q)
n[b]=o
return o}else return m},
kq(a,b){return A.iu(a.tR,b)},
kp(a,b){return A.iu(a.eT,b)},
d3(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.io(A.il(a,null,b,c))
r.set(b,s)
return s},
fr(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.io(A.il(a,b,c,!0))
q.set(c,r)
return r},
kr(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.he(a,b,c.w===10?c.y:[c])
p.set(s,q)
return q},
ak(a,b){b.a=A.kJ
b.b=A.kK
return b},
bR(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.a0(null,null)
s.w=b
s.as=c
r=A.ak(a,s)
a.eC.set(c,r)
return r},
it(a,b,c){var s,r=b.as+"*",q=a.eC.get(r)
if(q!=null)return q
s=A.kn(a,b,r,c)
a.eC.set(r,s)
return s},
kn(a,b,c,d){var s,r,q
if(d){s=b.w
if(!A.an(b))r=b===t.P||b===t.T||s===7||s===6
else r=!0
if(r)return b}q=new A.a0(null,null)
q.w=6
q.x=b
q.as=c
return A.ak(a,q)},
hg(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.km(a,b,r,c)
a.eC.set(r,s)
return s},
km(a,b,c,d){var s,r,q,p
if(d){s=b.w
r=!0
if(!A.an(b))if(!(b===t.P||b===t.T))if(s!==7)r=s===8&&A.c2(b.x)
if(r)return b
else if(s===1||b===t.L)return t.P
else if(s===6){q=b.x
if(q.w===8&&A.c2(q.x))return q
else return A.hU(a,b)}}p=new A.a0(null,null)
p.w=7
p.x=b
p.as=c
return A.ak(a,p)},
ir(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.kk(a,b,r,c)
a.eC.set(r,s)
return s},
kk(a,b,c,d){var s,r
if(d){s=b.w
if(A.an(b)||b===t.K||b===t._)return b
else if(s===1)return A.bQ(a,"ar",[b])
else if(b===t.P||b===t.T)return t.bc}r=new A.a0(null,null)
r.w=8
r.x=b
r.as=c
return A.ak(a,r)},
ko(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.a0(null,null)
s.w=14
s.x=b
s.as=q
r=A.ak(a,s)
a.eC.set(q,r)
return r},
bP(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
kj(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
bQ(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.bP(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.a0(null,null)
r.w=9
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.ak(a,r)
a.eC.set(p,q)
return q},
he(a,b,c){var s,r,q,p,o,n
if(b.w===10){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.bP(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.a0(null,null)
o.w=10
o.x=s
o.y=r
o.as=q
n=A.ak(a,o)
a.eC.set(q,n)
return n},
is(a,b,c){var s,r,q="+"+(b+"("+A.bP(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.a0(null,null)
s.w=11
s.x=b
s.y=c
s.as=q
r=A.ak(a,s)
a.eC.set(q,r)
return r},
iq(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.bP(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.bP(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.kj(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.a0(null,null)
p.w=12
p.x=b
p.y=c
p.as=r
o=A.ak(a,p)
a.eC.set(r,o)
return o},
hf(a,b,c,d){var s,r=b.as+("<"+A.bP(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.kl(a,b,c,r,d)
a.eC.set(r,s)
return s},
kl(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.fs(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.aC(a,b,r,0)
m=A.b7(a,c,r,0)
return A.hf(a,n,m,c!==m)}}l=new A.a0(null,null)
l.w=13
l.x=b
l.y=c
l.as=d
return A.ak(a,l)},
il(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
io(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.kc(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.im(a,r,l,k,!1)
else if(q===46)r=A.im(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.aA(a.u,a.e,k.pop()))
break
case 94:k.push(A.ko(a.u,k.pop()))
break
case 35:k.push(A.bR(a.u,5,"#"))
break
case 64:k.push(A.bR(a.u,2,"@"))
break
case 126:k.push(A.bR(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.ke(a,k)
break
case 38:A.kd(a,k)
break
case 42:p=a.u
k.push(A.it(p,A.aA(p,a.e,k.pop()),a.n))
break
case 63:p=a.u
k.push(A.hg(p,A.aA(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.ir(p,A.aA(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.kb(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.ip(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.kg(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-2)
break
case 43:n=l.indexOf("(",r)
k.push(l.substring(r,n))
k.push(-4)
k.push(a.p)
a.p=k.length
r=n+1
break
default:throw"Bad character "+q}}}m=k.pop()
return A.aA(a.u,a.e,m)},
kc(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
im(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===10)o=o.x
n=A.kt(s,o.x)[p]
if(n==null)A.a7('No "'+p+'" in "'+A.jU(o)+'"')
d.push(A.fr(s,o,n))}else d.push(p)
return m},
ke(a,b){var s,r=a.u,q=A.ik(a,b),p=b.pop()
if(typeof p=="string")b.push(A.bQ(r,p,q))
else{s=A.aA(r,a.e,p)
switch(s.w){case 12:b.push(A.hf(r,s,q,a.n))
break
default:b.push(A.he(r,s,q))
break}}},
kb(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.ik(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.aA(p,a.e,o)
q=new A.d_()
q.a=s
q.b=n
q.c=m
b.push(A.iq(p,r,q))
return
case-4:b.push(A.is(p,b.pop(),s))
return
default:throw A.b(A.c7("Unexpected state under `()`: "+A.z(o)))}},
kd(a,b){var s=b.pop()
if(0===s){b.push(A.bR(a.u,1,"0&"))
return}if(1===s){b.push(A.bR(a.u,4,"1&"))
return}throw A.b(A.c7("Unexpected extended operation "+A.z(s)))},
ik(a,b){var s=b.splice(a.p)
A.ip(a.u,a.e,s)
a.p=b.pop()
return s},
aA(a,b,c){if(typeof c=="string")return A.bQ(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.kf(a,b,c)}else return c},
ip(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.aA(a,b,c[s])},
kg(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.aA(a,b,c[s])},
kf(a,b,c){var s,r,q=b.w
if(q===10){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==9)throw A.b(A.c7("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.b(A.c7("Bad index "+c+" for "+b.i(0)))},
lr(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.D(a,b,null,c,null,!1)?1:0
r.set(c,s)}if(0===s)return!1
if(1===s)return!0
return!0},
D(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(!A.an(d))s=d===t._
else s=!0
if(s)return!0
r=b.w
if(r===4)return!0
if(A.an(b))return!1
s=b.w
if(s===1)return!0
q=r===14
if(q)if(A.D(a,c[b.x],c,d,e,!1))return!0
p=d.w
s=b===t.P||b===t.T
if(s){if(p===8)return A.D(a,b,c,d.x,e,!1)
return d===t.P||d===t.T||p===7||p===6}if(d===t.K){if(r===8)return A.D(a,b.x,c,d,e,!1)
if(r===6)return A.D(a,b.x,c,d,e,!1)
return r!==7}if(r===6)return A.D(a,b.x,c,d,e,!1)
if(p===6){s=A.hU(a,d)
return A.D(a,b,c,s,e,!1)}if(r===8){if(!A.D(a,b.x,c,d,e,!1))return!1
return A.D(a,A.h1(a,b),c,d,e,!1)}if(r===7){s=A.D(a,t.P,c,d,e,!1)
return s&&A.D(a,b.x,c,d,e,!1)}if(p===8){if(A.D(a,b,c,d.x,e,!1))return!0
return A.D(a,b,c,A.h1(a,d),e,!1)}if(p===7){s=A.D(a,b,c,t.P,e,!1)
return s||A.D(a,b,c,d.x,e,!1)}if(q)return!1
s=r!==12
if((!s||r===13)&&d===t.Z)return!0
o=r===11
if(o&&d===t.cY)return!0
if(p===13){if(b===t.g)return!0
if(r!==13)return!1
n=b.y
m=d.y
l=n.length
if(l!==m.length)return!1
c=c==null?n:n.concat(c)
e=e==null?m:m.concat(e)
for(k=0;k<l;++k){j=n[k]
i=m[k]
if(!A.D(a,j,c,i,e,!1)||!A.D(a,i,e,j,c,!1))return!1}return A.iz(a,b.x,c,d.x,e,!1)}if(p===12){if(b===t.g)return!0
if(s)return!1
return A.iz(a,b,c,d,e,!1)}if(r===9){if(p!==9)return!1
return A.kQ(a,b,c,d,e,!1)}if(o&&p===11)return A.kU(a,b,c,d,e,!1)
return!1},
iz(a3,a4,a5,a6,a7,a8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.D(a3,a4.x,a5,a6.x,a7,!1))return!1
s=a4.y
r=a6.y
q=s.a
p=r.a
o=q.length
n=p.length
if(o>n)return!1
m=n-o
l=s.b
k=r.b
j=l.length
i=k.length
if(o+j<n+i)return!1
for(h=0;h<o;++h){g=q[h]
if(!A.D(a3,p[h],a7,g,a5,!1))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.D(a3,p[o+h],a7,g,a5,!1))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.D(a3,k[h],a7,g,a5,!1))return!1}f=s.c
e=r.c
d=f.length
c=e.length
for(b=0,a=0;a<c;a+=3){a0=e[a]
for(;!0;){if(b>=d)return!1
a1=f[b]
b+=3
if(a0<a1)return!1
a2=f[b-2]
if(a1<a0){if(a2)return!1
continue}g=e[a+1]
if(a2&&!g)return!1
g=f[b-1]
if(!A.D(a3,e[a+2],a7,g,a5,!1))return!1
break}}for(;b<d;){if(f[b+1])return!1
b+=3}return!0},
kQ(a,b,c,d,e,f){var s,r,q,p,o,n=b.x,m=d.x
for(;n!==m;){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.fr(a,b,r[o])
return A.iv(a,p,null,c,d.y,e,!1)}return A.iv(a,b.y,null,c,d.y,e,!1)},
iv(a,b,c,d,e,f,g){var s,r=b.length
for(s=0;s<r;++s)if(!A.D(a,b[s],d,e[s],f,!1))return!1
return!0},
kU(a,b,c,d,e,f){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.D(a,r[s],c,q[s],e,!1))return!1
return!0},
c2(a){var s=a.w,r=!0
if(!(a===t.P||a===t.T))if(!A.an(a))if(s!==7)if(!(s===6&&A.c2(a.x)))r=s===8&&A.c2(a.x)
return r},
lp(a){var s
if(!A.an(a))s=a===t._
else s=!0
return s},
an(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.X},
iu(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
fs(a){return a>0?new Array(a):v.typeUniverse.sEA},
a0:function a0(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
d_:function d_(){this.c=this.b=this.a=null},
fq:function fq(a){this.a=a},
cZ:function cZ(){},
bO:function bO(a){this.a=a},
k_(){var s,r,q={}
if(self.scheduleImmediate!=null)return A.la()
if(self.MutationObserver!=null&&self.document!=null){s=self.document.createElement("div")
r=self.document.createElement("span")
q.a=null
new self.MutationObserver(A.c1(new A.f_(q),1)).observe(s,{childList:true})
return new A.eZ(q,s,r)}else if(self.setImmediate!=null)return A.lb()
return A.lc()},
k0(a){self.scheduleImmediate(A.c1(new A.f0(t.M.a(a)),0))},
k1(a){self.setImmediate(A.c1(new A.f1(t.M.a(a)),0))},
k2(a){t.M.a(a)
A.kh(0,a)},
kh(a,b){var s=new A.fo()
s.bK(a,b)
return s},
bZ(a){return new A.bA(new A.C($.v,a.h("C<0>")),a.h("bA<0>"))},
bW(a,b){a.$2(0,null)
b.b=!0
return b.a},
hh(a,b){A.ky(a,b)},
bV(a,b){b.aC(a)},
bU(a,b){b.b0(A.aH(a),A.aF(a))},
ky(a,b){var s,r,q=new A.ft(b),p=new A.fu(b)
if(a instanceof A.C)a.bs(q,p,t.z)
else{s=t.z
if(a instanceof A.C)a.aF(q,p,s)
else{r=new A.C($.v,t.d)
r.a=8
r.c=a
r.bs(q,p,s)}}},
c_(a){var s=function(b,c){return function(d,e){while(true){try{b(d,e)
break}catch(r){e=r
d=c}}}}(a,1)
return $.v.bz(new A.fy(s),t.H,t.S,t.z)},
fR(a){var s
if(t.C.b(a)){s=a.ga_()
if(s!=null)return s}return B.o},
kM(a,b){if($.v===B.c)return null
return null},
kN(a,b){if($.v!==B.c)A.kM(a,b)
if(b==null)if(t.C.b(a)){b=a.ga_()
if(b==null){A.hR(a,B.o)
b=B.o}}else b=B.o
else if(t.C.b(a))A.hR(a,b)
return new A.ad(a,b)},
ij(a,b){var s,r,q
for(s=t.d;r=a.a,(r&4)!==0;)a=s.a(a.c)
if(a===b){b.an(new A.a4(!0,a,null,"Cannot complete a future with itself"),A.i_())
return}s=r|b.a&1
a.a=s
if((s&24)!==0){q=b.aU()
b.ao(a)
A.bF(b,q)}else{q=t.F.a(b.c)
b.bm(a)
a.aT(q)}},
ka(a,b){var s,r,q,p={},o=p.a=a
for(s=t.d;r=o.a,(r&4)!==0;o=a){a=s.a(o.c)
p.a=a}if(o===b){b.an(new A.a4(!0,o,null,"Cannot complete a future with itself"),A.i_())
return}if((r&24)===0){q=t.F.a(b.c)
b.bm(o)
p.a.aT(q)
return}if((r&16)===0&&b.c==null){b.ao(o)
return}b.a^=2
A.b6(null,null,b.b,t.M.a(new A.fb(p,b)))},
bF(a,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c={},b=c.a=a
for(s=t.n,r=t.F,q=t.e;!0;){p={}
o=b.a
n=(o&16)===0
m=!n
if(a0==null){if(m&&(o&1)===0){l=s.a(b.c)
A.hk(l.a,l.b)}return}p.a=a0
k=a0.a
for(b=a0;k!=null;b=k,k=j){b.a=null
A.bF(c.a,b)
p.a=k
j=k.a}o=c.a
i=o.c
p.b=m
p.c=i
if(n){h=b.c
h=(h&1)!==0||(h&15)===8}else h=!0
if(h){g=b.b.b
if(m){o=o.b===g
o=!(o||o)}else o=!1
if(o){s.a(i)
A.hk(i.a,i.b)
return}f=$.v
if(f!==g)$.v=g
else f=null
b=b.c
if((b&15)===8)new A.fi(p,c,m).$0()
else if(n){if((b&1)!==0)new A.fh(p,i).$0()}else if((b&2)!==0)new A.fg(c,p).$0()
if(f!=null)$.v=f
b=p.c
if(b instanceof A.C){o=p.a.$ti
o=o.h("ar<2>").b(b)||!o.y[1].b(b)}else o=!1
if(o){q.a(b)
e=p.a.b
if((b.a&24)!==0){d=r.a(e.c)
e.c=null
a0=e.av(d)
e.a=b.a&30|e.a&1
e.c=b.c
c.a=b
continue}else A.ij(b,e)
return}}e=p.a.b
d=r.a(e.c)
e.c=null
a0=e.av(d)
b=p.b
o=p.c
if(!b){e.$ti.c.a(o)
e.a=8
e.c=o}else{s.a(o)
e.a=e.a&1|16
e.c=o}c.a=e
b=e}},
iD(a,b){var s
if(t.U.b(a))return b.bz(a,t.z,t.K,t.l)
s=t.v
if(s.b(a))return s.a(a)
throw A.b(A.hv(a,"onError",u.c))},
kZ(){var s,r
for(s=$.b5;s!=null;s=$.b5){$.bY=null
r=s.b
$.b5=r
if(r==null)$.bX=null
s.a.$0()}},
l3(){$.hj=!0
try{A.kZ()}finally{$.bY=null
$.hj=!1
if($.b5!=null)$.hr().$1(A.iI())}},
iG(a){var s=new A.cU(a),r=$.bX
if(r==null){$.b5=$.bX=s
if(!$.hj)$.hr().$1(A.iI())}else $.bX=r.b=s},
l2(a){var s,r,q,p=$.b5
if(p==null){A.iG(a)
$.bY=$.bX
return}s=new A.cU(a)
r=$.bY
if(r==null){s.b=p
$.b5=$.bY=s}else{q=r.b
s.b=q
$.bY=r.b=s
if(q==null)$.bX=s}},
lx(a){var s=null,r=$.v
if(B.c===r){A.b6(s,s,B.c,a)
return}A.b6(s,s,r,t.M.a(r.bv(a)))},
lG(a,b){A.fz(a,"stream",t.K)
return new A.d1(b.h("d1<0>"))},
hk(a,b){A.l2(new A.fx(a,b))},
iE(a,b,c,d,e){var s,r=$.v
if(r===c)return d.$0()
$.v=c
s=r
try{r=d.$0()
return r}finally{$.v=s}},
l1(a,b,c,d,e,f,g){var s,r=$.v
if(r===c)return d.$1(e)
$.v=c
s=r
try{r=d.$1(e)
return r}finally{$.v=s}},
l0(a,b,c,d,e,f,g,h,i){var s,r=$.v
if(r===c)return d.$2(e,f)
$.v=c
s=r
try{r=d.$2(e,f)
return r}finally{$.v=s}},
b6(a,b,c,d){t.M.a(d)
if(B.c!==c)d=c.bv(d)
A.iG(d)},
f_:function f_(a){this.a=a},
eZ:function eZ(a,b,c){this.a=a
this.b=b
this.c=c},
f0:function f0(a){this.a=a},
f1:function f1(a){this.a=a},
fo:function fo(){},
fp:function fp(a,b){this.a=a
this.b=b},
bA:function bA(a,b){this.a=a
this.b=!1
this.$ti=b},
ft:function ft(a){this.a=a},
fu:function fu(a){this.a=a},
fy:function fy(a){this.a=a},
ad:function ad(a,b){this.a=a
this.b=b},
bD:function bD(){},
aO:function aO(a,b){this.a=a
this.$ti=b},
aj:function aj(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
C:function C(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
f8:function f8(a,b){this.a=a
this.b=b},
ff:function ff(a,b){this.a=a
this.b=b},
fc:function fc(a){this.a=a},
fd:function fd(a){this.a=a},
fe:function fe(a,b,c){this.a=a
this.b=b
this.c=c},
fb:function fb(a,b){this.a=a
this.b=b},
fa:function fa(a,b){this.a=a
this.b=b},
f9:function f9(a,b,c){this.a=a
this.b=b
this.c=c},
fi:function fi(a,b,c){this.a=a
this.b=b
this.c=c},
fj:function fj(a){this.a=a},
fh:function fh(a,b){this.a=a
this.b=b},
fg:function fg(a,b){this.a=a
this.b=b},
cU:function cU(a){this.a=a
this.b=null},
d1:function d1(a){this.$ti=a},
bS:function bS(){},
fx:function fx(a,b){this.a=a
this.b=b},
d0:function d0(){},
fn:function fn(a,b){this.a=a
this.b=b},
hb(a,b){var s=a[b]
return s===a?null:s},
hd(a,b,c){if(c==null)a[b]=a
else a[b]=c},
hc(){var s=Object.create(null)
A.hd(s,"<non-identifier-key>",s)
delete s["<non-identifier-key>"]
return s},
jv(a,b){return new A.ag(a.h("@<0>").l(b).h("ag<1,2>"))},
u(a,b,c){return b.h("@<0>").l(c).h("hL<1,2>").a(A.lg(a,new A.ag(b.h("@<0>").l(c).h("ag<1,2>"))))},
hM(a,b){return new A.ag(a.h("@<0>").l(b).h("ag<1,2>"))},
hN(a,b,c){var s=A.jv(b,c)
a.Y(0,new A.dK(s,b,c))
return s},
h0(a){var s,r={}
if(A.hn(a))return"{...}"
s=new A.cJ("")
try{B.a.k($.Y,a)
s.a+="{"
r.a=!0
a.Y(0,new A.dM(r,s))
s.a+="}"}finally{if(0>=$.Y.length)return A.e($.Y,-1)
$.Y.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
bG:function bG(){},
b4:function b4(a){var _=this
_.a=0
_.e=_.d=_.c=_.b=null
_.$ti=a},
bH:function bH(a,b){this.a=a
this.$ti=b},
bI:function bI(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
dK:function dK(a,b,c){this.a=a
this.b=b
this.c=c},
o:function o(){},
x:function x(){},
dM:function dM(a,b){this.a=a
this.b=b},
ha(a,b){var s=A.k9(a,b)
if(s==null)throw A.b(A.hD("Could not parse BigInt",a))
return s},
k6(a,b){var s,r,q=$.ao(),p=a.length,o=4-p%4
if(o===4)o=0
for(s=0,r=0;r<p;++r){s=s*10+a.charCodeAt(r)-48;++o
if(o===4){q=q.ak(0,$.hs()).bB(0,A.cV(s))
s=0
o=0}}if(b)return q.K(0)
return q},
ia(a){if(48<=a&&a<=57)return a-48
return(a|32)-97+10},
k7(a,b,c){var s,r,q,p,o,n,m,l=a.length,k=l-b,j=B.U.ct(k/4),i=new Uint16Array(j),h=j-1,g=k-h*4
for(s=b,r=0,q=0;q<g;++q,s=p){p=s+1
if(!(s<l))return A.e(a,s)
o=A.ia(a.charCodeAt(s))
if(o>=16)return null
r=r*16+o}n=h-1
if(!(h>=0&&h<j))return A.e(i,h)
i[h]=r
for(;s<l;n=m){for(r=0,q=0;q<4;++q,s=p){p=s+1
if(!(s>=0&&s<l))return A.e(a,s)
o=A.ia(a.charCodeAt(s))
if(o>=16)return null
r=r*16+o}m=n-1
if(!(n>=0&&n<j))return A.e(i,n)
i[n]=r}if(j===1){if(0>=j)return A.e(i,0)
l=i[0]===0}else l=!1
if(l)return $.ao()
l=A.a3(j,i)
return new A.M(l===0?!1:c,i,l)},
k9(a,b){var s,r,q,p,o,n
if(a==="")return null
s=$.j4().cz(a)
if(s==null)return null
r=s.b
q=r.length
if(1>=q)return A.e(r,1)
p=r[1]==="-"
if(4>=q)return A.e(r,4)
o=r[4]
n=r[3]
if(5>=q)return A.e(r,5)
if(o!=null)return A.k6(o,p)
if(n!=null)return A.k7(n,2,p)
return null},
a3(a,b){var s,r=b.length
while(!0){if(a>0){s=a-1
if(!(s<r))return A.e(b,s)
s=b[s]===0}else s=!1
if(!s)break;--a}return a},
h8(a,b,c,d){var s,r,q,p=new Uint16Array(d),o=c-b
for(s=a.length,r=0;r<o;++r){q=b+r
if(!(q>=0&&q<s))return A.e(a,q)
q=a[q]
if(!(r<d))return A.e(p,r)
p[r]=q}return p},
cV(a){var s,r,q,p,o=a<0
if(o){if(a===-9223372036854776e3){s=new Uint16Array(4)
s[3]=32768
r=A.a3(4,s)
return new A.M(r!==0,s,r)}a=-a}if(a<65536){s=new Uint16Array(1)
s[0]=a
r=A.a3(1,s)
return new A.M(r===0?!1:o,s,r)}if(a<=4294967295){s=new Uint16Array(2)
s[0]=a&65535
s[1]=B.b.af(a,16)
r=A.a3(2,s)
return new A.M(r===0?!1:o,s,r)}r=B.b.S(B.b.gbw(a)-1,16)+1
s=new Uint16Array(r)
for(q=0;a!==0;q=p){p=q+1
if(!(q<r))return A.e(s,q)
s[q]=a&65535
a=B.b.S(a,65536)}r=A.a3(r,s)
return new A.M(r===0?!1:o,s,r)},
h9(a,b,c,d){var s,r,q,p,o
if(b===0)return 0
if(c===0&&d===a)return b
for(s=b-1,r=a.length,q=d.$flags|0;s>=0;--s){p=s+c
if(!(s<r))return A.e(a,s)
o=a[s]
q&2&&A.I(d)
if(!(p>=0&&p<d.length))return A.e(d,p)
d[p]=o}for(s=c-1;s>=0;--s){q&2&&A.I(d)
if(!(s<d.length))return A.e(d,s)
d[s]=0}return b+c},
k5(a,b,c,d){var s,r,q,p,o,n,m,l=B.b.S(c,16),k=B.b.aj(c,16),j=16-k,i=B.b.a7(1,j)-1
for(s=b-1,r=a.length,q=d.$flags|0,p=0;s>=0;--s){if(!(s<r))return A.e(a,s)
o=a[s]
n=s+l+1
m=B.b.aX(o,j)
q&2&&A.I(d)
if(!(n>=0&&n<d.length))return A.e(d,n)
d[n]=(m|p)>>>0
p=B.b.a7((o&i)>>>0,k)}q&2&&A.I(d)
if(!(l>=0&&l<d.length))return A.e(d,l)
d[l]=p},
ib(a,b,c,d){var s,r,q,p=B.b.S(c,16)
if(B.b.aj(c,16)===0)return A.h9(a,b,p,d)
s=b+p+1
A.k5(a,b,c,d)
for(r=d.$flags|0,q=p;--q,q>=0;){r&2&&A.I(d)
if(!(q<d.length))return A.e(d,q)
d[q]=0}r=s-1
if(!(r>=0&&r<d.length))return A.e(d,r)
if(d[r]===0)s=r
return s},
k8(a,b,c,d){var s,r,q,p,o,n,m=B.b.S(c,16),l=B.b.aj(c,16),k=16-l,j=B.b.a7(1,l)-1,i=a.length
if(!(m>=0&&m<i))return A.e(a,m)
s=B.b.aX(a[m],l)
r=b-m-1
for(q=d.$flags|0,p=0;p<r;++p){o=p+m+1
if(!(o<i))return A.e(a,o)
n=a[o]
o=B.b.a7((n&j)>>>0,k)
q&2&&A.I(d)
if(!(p<d.length))return A.e(d,p)
d[p]=(o|s)>>>0
s=B.b.aX(n,l)}q&2&&A.I(d)
if(!(r>=0&&r<d.length))return A.e(d,r)
d[r]=s},
f2(a,b,c,d){var s,r,q,p,o=b-d
if(o===0)for(s=b-1,r=a.length,q=c.length;s>=0;--s){if(!(s<r))return A.e(a,s)
p=a[s]
if(!(s<q))return A.e(c,s)
o=p-c[s]
if(o!==0)return o}return o},
k3(a,b,c,d,e){var s,r,q,p,o,n
for(s=a.length,r=c.length,q=e.$flags|0,p=0,o=0;o<d;++o){if(!(o<s))return A.e(a,o)
n=a[o]
if(!(o<r))return A.e(c,o)
p+=n+c[o]
q&2&&A.I(e)
if(!(o<e.length))return A.e(e,o)
e[o]=p&65535
p=p>>>16}for(o=d;o<b;++o){if(!(o>=0&&o<s))return A.e(a,o)
p+=a[o]
q&2&&A.I(e)
if(!(o<e.length))return A.e(e,o)
e[o]=p&65535
p=p>>>16}q&2&&A.I(e)
if(!(b>=0&&b<e.length))return A.e(e,b)
e[b]=p},
cW(a,b,c,d,e){var s,r,q,p,o,n
for(s=a.length,r=c.length,q=e.$flags|0,p=0,o=0;o<d;++o){if(!(o<s))return A.e(a,o)
n=a[o]
if(!(o<r))return A.e(c,o)
p+=n-c[o]
q&2&&A.I(e)
if(!(o<e.length))return A.e(e,o)
e[o]=p&65535
p=0-(B.b.af(p,16)&1)}for(o=d;o<b;++o){if(!(o>=0&&o<s))return A.e(a,o)
p+=a[o]
q&2&&A.I(e)
if(!(o<e.length))return A.e(e,o)
e[o]=p&65535
p=0-(B.b.af(p,16)&1)}},
ih(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k
if(a===0)return
for(s=b.length,r=d.length,q=d.$flags|0,p=0;--f,f>=0;e=l,c=o){o=c+1
if(!(c<s))return A.e(b,c)
n=b[c]
if(!(e>=0&&e<r))return A.e(d,e)
m=a*n+d[e]+p
l=e+1
q&2&&A.I(d)
d[e]=m&65535
p=B.b.S(m,65536)}for(;p!==0;e=l){if(!(e>=0&&e<r))return A.e(d,e)
k=d[e]+p
l=e+1
q&2&&A.I(d)
d[e]=k&65535
p=B.b.S(k,65536)}},
k4(a,b,c){var s,r,q,p=b.length
if(!(c>=0&&c<p))return A.e(b,c)
s=b[c]
if(s===a)return 65535
r=c-1
if(!(r>=0&&r<p))return A.e(b,r)
q=B.b.bI((s<<16|b[r])>>>0,a)
if(q>65535)return 65535
return q},
jl(a,b){a=A.b(a)
if(a==null)a=t.K.a(a)
a.stack=b.i(0)
throw a
throw A.b("unreachable")},
hO(a,b,c,d){var s,r=c?J.hG(a,d):J.jp(a,d)
if(a!==0&&b!=null)for(s=0;s<r.length;++s)r[s]=b
return r},
jx(a,b,c){var s,r=A.d([],c.h("m<0>"))
for(s=J.ba(a);s.n();)B.a.k(r,c.a(s.gp()))
r.$flags=1
return r},
B(a,b,c){var s=A.jw(a,c)
return s},
jw(a,b){var s,r
if(Array.isArray(a))return A.d(a.slice(0),b.h("m<0>"))
s=A.d([],b.h("m<0>"))
for(r=J.ba(a);r.n();)B.a.k(s,r.gp())
return s},
jy(a,b,c){var s,r=J.hG(a,c)
for(s=0;s<a;++s)B.a.t(r,s,b.$1(s))
return r},
a5(a,b){var s=A.jx(a,!1,b)
s.$flags=3
return s},
i2(a){A.hT(0,"start")
return A.jO(A.B(a,!0,t.S))},
jT(a,b){return new A.cm(a,A.jt(a,!1,!1,!1,!1,!1))},
i1(a,b,c){var s=J.ba(b)
if(!s.n())return a
if(c.length===0){do a+=A.z(s.gp())
while(s.n())}else{a+=A.z(s.gp())
for(;s.n();)a=a+c+A.z(s.gp())}return a},
i_(){return A.aF(new Error())},
jj(a){var s=Math.abs(a),r=a<0?"-":""
if(s>=1000)return""+a
if(s>=100)return r+"0"+s
if(s>=10)return r+"00"+s
return r+"000"+s},
hC(a){if(a>=100)return""+a
if(a>=10)return"0"+a
return"00"+a},
cd(a){if(a>=10)return""+a
return"0"+a},
ce(a){if(typeof a=="number"||A.fv(a)||a==null)return J.bb(a)
if(typeof a=="string")return JSON.stringify(a)
return A.jN(a)},
jm(a,b){A.fz(a,"error",t.K)
A.fz(b,"stackTrace",t.l)
A.jl(a,b)},
c7(a){return new A.bd(a)},
a9(a,b){return new A.a4(!1,null,b,a)},
hv(a,b,c){return new A.a4(!0,a,b,c)},
ax(a,b,c,d,e){return new A.b2(b,c,!0,a,d,"Invalid value")},
jR(a,b,c){if(0>a||a>c)throw A.b(A.ax(a,0,c,"start",null))
if(a>b||b>c)throw A.b(A.ax(b,a,c,"end",null))
return b},
hT(a,b){if(a<0)throw A.b(A.ax(a,0,null,b,null))
return a},
hE(a,b,c,d){return new A.cg(b,!0,a,d,"Index out of range")},
cR(a){return new A.by(a)},
i6(a){return new A.cP(a)},
i0(a){return new A.b3(a)},
aq(a){return new A.cb(a)},
hD(a,b){return new A.di(a,b)},
jo(a,b,c){var s,r
if(A.hn(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.d([],t.s)
B.a.k($.Y,a)
try{A.kY(a,s)}finally{if(0>=$.Y.length)return A.e($.Y,-1)
$.Y.pop()}r=A.i1(b,t.bi.a(s),", ")+c
return r.charCodeAt(0)==0?r:r},
hF(a,b,c){var s,r
if(A.hn(a))return b+"..."+c
s=new A.cJ(b)
B.a.k($.Y,a)
try{r=s
r.a=A.i1(r.a,a,", ")}finally{if(0>=$.Y.length)return A.e($.Y,-1)
$.Y.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
kY(a,b){var s,r,q,p,o,n,m,l=a.gA(a),k=0,j=0
while(!0){if(!(k<80||j<3))break
if(!l.n())return
s=A.z(l.gp())
B.a.k(b,s)
k+=s.length+2;++j}if(!l.n()){if(j<=5)return
if(0>=b.length)return A.e(b,-1)
r=b.pop()
if(0>=b.length)return A.e(b,-1)
q=b.pop()}else{p=l.gp();++j
if(!l.n()){if(j<=4){B.a.k(b,A.z(p))
return}r=A.z(p)
if(0>=b.length)return A.e(b,-1)
q=b.pop()
k+=r.length+2}else{o=l.gp();++j
for(;l.n();p=o,o=n){n=l.gp();++j
if(j>100){while(!0){if(!(k>75&&j>3))break
if(0>=b.length)return A.e(b,-1)
k-=b.pop().length+2;--j}B.a.k(b,"...")
return}}q=A.z(p)
r=A.z(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
while(!0){if(!(k>80&&b.length>3))break
if(0>=b.length)return A.e(b,-1)
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)B.a.k(b,m)
B.a.k(b,q)
B.a.k(b,r)},
jD(a,b){var s=B.b.gq(a)
b=B.b.gq(b)
b=A.jV(A.i3(A.i3($.j5(),s),b))
return b},
M:function M(a,b,c){this.a=a
this.b=b
this.c=c},
f3:function f3(){},
f4:function f4(){},
cc:function cc(a,b,c){this.a=a
this.b=b
this.c=c},
f6:function f6(){},
r:function r(){},
bd:function bd(a){this.a=a},
ah:function ah(){},
a4:function a4(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
b2:function b2(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
cg:function cg(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
by:function by(a){this.a=a},
cP:function cP(a){this.a=a},
b3:function b3(a){this.a=a},
cb:function cb(a){this.a=a},
cw:function cw(){},
bv:function bv(){},
f7:function f7(a){this.a=a},
di:function di(a,b){this.a=a
this.b=b},
ch:function ch(){},
h:function h(){},
G:function G(){},
c:function c(){},
d2:function d2(){},
cJ:function cJ(a){this.a=a},
l(a){var s
if(typeof a=="function")throw A.b(A.a9("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(){return b(c)}}(A.kz,a)
s[$.c4()]=a
return s},
A(a){var s
if(typeof a=="function")throw A.b(A.a9("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d){return b(c,d,arguments.length)}}(A.kA,a)
s[$.c4()]=a
return s},
t(a){var s
if(typeof a=="function")throw A.b(A.a9("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e){return b(c,d,e,arguments.length)}}(A.kB,a)
s[$.c4()]=a
return s},
aB(a){var s
if(typeof a=="function")throw A.b(A.a9("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e,f,g){return b(c,d,e,f,g,arguments.length)}}(A.kC,a)
s[$.c4()]=a
return s},
kz(a){return t.Z.a(a).$0()},
kA(a,b,c){t.Z.a(a)
if(A.X(c)>=1)return a.$1(b)
return a.$0()},
kB(a,b,c,d){t.Z.a(a)
A.X(d)
if(d>=2)return a.$2(b,c)
if(d===1)return a.$1(b)
return a.$0()},
kC(a,b,c,d,e,f){t.Z.a(a)
A.X(f)
if(f>=4)return a.$4(b,c,d,e)
if(f===3)return a.$3(b,c,d)
if(f===2)return a.$2(b,c)
if(f===1)return a.$1(b)
return a.$0()},
iC(a){return a==null||A.fv(a)||typeof a=="number"||typeof a=="string"||t.by.b(a)||t.bX.b(a)||t.ca.b(a)||t.h.b(a)||t.c0.b(a)||t.c8.b(a)||t.bk.b(a)||t.W.b(a)||t.q.b(a)||t.E.b(a)||t.Y.b(a)},
N(a){if(A.iC(a))return a
return new A.fJ(new A.b4(t.J)).$1(a)},
aD(a,b,c){var s,r
if(b instanceof Array)switch(b.length){case 0:return c.a(new a())
case 1:return c.a(new a(b[0]))
case 2:return c.a(new a(b[0],b[1]))
case 3:return c.a(new a(b[0],b[1],b[2]))
case 4:return c.a(new a(b[0],b[1],b[2],b[3]))}s=[null]
B.a.b_(s,b)
r=a.bind.apply(a,s)
String(r)
return c.a(new r())},
lv(a,b){var s=new A.C($.v,b.h("C<0>")),r=new A.aO(s,b.h("aO<0>"))
a.then(A.c1(new A.fM(r,b),1),A.c1(new A.fN(r),1))
return s},
iB(a){return a==null||typeof a==="boolean"||typeof a==="number"||typeof a==="string"||a instanceof Int8Array||a instanceof Uint8Array||a instanceof Uint8ClampedArray||a instanceof Int16Array||a instanceof Uint16Array||a instanceof Int32Array||a instanceof Uint32Array||a instanceof Float32Array||a instanceof Float64Array||a instanceof ArrayBuffer||a instanceof DataView},
am(a){if(A.iB(a))return a
return new A.fA(new A.b4(t.J)).$1(a)},
fJ:function fJ(a){this.a=a},
fM:function fM(a,b){this.a=a
this.b=b},
fN:function fN(a){this.a=a},
fA:function fA(a){this.a=a},
dN:function dN(a){this.a=a},
fk:function fk(a){this.a=a},
jX(){var s,r,q,p=A.jy(16,new A.eK($.iR()),t.S)
B.a.t(p,6,p[6]&15|64)
B.a.t(p,8,p[8]&63|128)
s=A.F(p)
r=s.h("y<1,j>")
q=A.B(new A.y(p,s.h("j(1)").a(new A.eL()),r),!0,r.h("w.E"))
return B.a.ah(B.a.a8(q,0,4),"")+"-"+B.a.ah(B.a.a8(q,4,6),"")+"-"+B.a.ah(B.a.a8(q,6,8),"")+"-"+B.a.ah(B.a.a8(q,8,10),"")+"-"+B.a.ah(B.a.bF(q,10),"")},
eK:function eK(a){this.a=a},
eL:function eL(){},
jz(a){var s=t.r.a(self.Object.keys(a))
if(s==null)s=null
else{s=t.aY.b(s)?s:new A.K(s,A.F(s).h("K<1,j>"))
s=J.c6(s,new A.dL(),t.N)
s=A.B(s,!0,s.$ti.h("w.E"))}return s},
h_(a,b,c){var s,r,q,p
try{s=A.jz(b)
if(s==null)return null
for(q=0;q<2;++q){r=a[q]
if(!J.j8(s,r))return null}c.a(b)
return b}catch(p){return null}},
dL:function dL(){},
db:function db(){},
dI:function dI(){},
aN:function aN(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
cS:function cS(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
eV:function eV(){},
eW:function eW(){},
d5:function d5(){},
d6:function d6(){},
eX:function eX(){},
jY(a){return A.hS($.jZ,new A.eY(a),t.k)},
a6:function a6(a,b){this.b=a
this.c=b},
eY:function eY(a){this.a=a},
cA:function cA(a,b){this.a=a
this.b=b},
jk(a){var s=self,r=t.m,q=r.a(new s.CustomEvent("eip6963:announceProvider",{bubbles:!0,cancelable:!1,detail:t.K.a(s.Object.freeze({info:$.fO(),provider:a}))}))
r.a(s.window).addEventListener("eip6963:requestProvider",A.A(new A.dd(q)))
r.a(s.window).dispatchEvent(q)},
O:function O(a,b){this.a=a
this.$ti=b},
dd:function dd(a){this.a=a},
fU:function fU(a,b){this.a=a
this.b=b},
cD:function cD(a,b){this.a=a
this.b=b},
dR:function dR(a){this.a=a},
dS:function dS(a){this.a=a},
hK(a,b){var s,r=a.H()
if(r.j(0,"stack")==null)r.t(0,"stack",b)
s=A.N(r)
if(s==null)s={}
s.toString=A.l(new A.dD(a))
return s},
aX(a){var s,r=A.hN(a,t.N,t.z)
if(r.j(0,"stack")==null)r.t(0,"stack",null)
r.bA(0,new A.dB())
s=A.N(r)
if(s==null)s={}
s.toString=A.l(new A.dC(a))
return s},
jW(a){return A.hK(a,null)},
dD:function dD(a){this.a=a},
dB:function dB(){},
dC:function dC(a){this.a=a},
a2(a,b){return t.m.a(new self.Promise(A.t(new A.eU(a))))},
jQ(a,b){return A.aD(self.Proxy,[a,new A.dU(new A.O(a,b.h("O<0>"))).$0()],t.m)},
eU:function eU(a){this.a=a},
eR:function eR(a){this.a=a},
eS:function eS(a){this.a=a},
eT:function eT(a,b){this.a=a
this.b=b},
dT:function dT(a){this.a=a},
dU:function dU(a){this.a=a},
ho(a){return A.lt(a)},
lt(a){var s=0,r=A.bZ(t.H),q,p
var $async$ho=A.c_(function(b,c){if(b===1)return A.bU(c,r)
while(true)switch(s){case 0:q={}
p=self
p.MRT={}
q.a=!1
t.m.a(p.window).addEventListener("WALLET_ACTIVATION",A.A(new A.fK(q)))
return A.bV(null,r)}})
return A.bW($async$ho,r)},
fK:function fK(a){this.a=a},
ju(a){return B.a.a3(B.a1,new A.dE(a),new A.dF())},
bz(a){var s=a.data
return A.f(s==null?null:A.am(s))},
i7(a,b){b.Y(0,new A.eQ(b,a))
return A.hN(b,t.N,t.z)},
J(a){var s=a.data
s=s==null?null:A.am(s)
return A.i7(a,t.f.a(s))},
ab(a){return B.a.a3(B.G,new A.dr(a),new A.ds())},
ae(a){return A.hS(B.G,new A.dq(a),t.A)},
fW(a){return B.a.a3(B.Z,new A.dG(a),new A.dH())},
jr(a){return B.a.a3(B.a0,new A.dn(a),new A.dp())},
fV(a,b,c,d){var s,r
try{s=d.a(c.h("0?").a(a[b]))
return s}catch(r){d.a(null)
return null}},
aw(a,b,c){var s=a==null?"":a
return{type:"request",method:b,params:c,id:s,additionalData:null}},
cx(a){return{type:"event",event:a.b,data:null}},
at:function at(a){this.b=a},
dE:function dE(a){this.a=a},
dF:function dF(){},
eQ:function eQ(a,b){this.a=a
this.b=b},
R:function R(a){this.b=a},
dr:function dr(a){this.a=a},
ds:function ds(){},
dq:function dq(a){this.a=a},
au:function au(a){this.b=a},
dG:function dG(a){this.a=a},
dH:function dH(){},
a_:function a_(a){this.b=a},
dn:function dn(a){this.a=a},
dp:function dp(){},
dm:function dm(){},
cl:function cl(){var _=this
_.e=_.d=_.c=_.b=_.a=$},
cy:function cy(){},
cf:function cf(a,b){var _=this
_.d=0
_.e=null
_.a=a
_.b=0
_.c=b},
de:function de(a){this.a=a},
df:function df(a){this.a=a},
cF:function cF(a,b){var _=this
_.d=null
_.a=a
_.b=0
_.c=b},
e3:function e3(a){this.a=a},
e4:function e4(a){this.a=a},
e5:function e5(a){this.a=a},
e6:function e6(a){this.a=a},
e8:function e8(a){this.a=a},
dZ:function dZ(){},
e_:function e_(a,b,c){this.a=a
this.b=b
this.c=c},
e0:function e0(){},
e9:function e9(a){this.a=a},
ea:function ea(a,b,c){this.a=a
this.b=b
this.c=c},
e7:function e7(){},
e2:function e2(){},
e1:function e1(){},
eb:function eb(){},
cI:function cI(a,b){var _=this
_.d=null
_.a=a
_.b=0
_.c=b},
em:function em(a){this.a=a},
en:function en(a){this.a=a},
cM:function cM(a,b){var _=this
_.d=null
_.a=a
_.b=0
_.c=b},
es:function es(a){this.a=a},
et:function et(a){this.a=a},
cO:function cO(a,b){var _=this
_.e=_.d=null
_.a=a
_.b=0
_.c=b},
ez:function ez(a){this.a=a},
eA:function eA(a){this.a=a},
ey:function ey(a){this.a=a},
eB:function eB(a){this.a=a},
ex:function ex(a){this.a=a},
eC:function eC(a){this.a=a},
ew:function ew(a){this.a=a},
eD:function eD(a){this.a=a},
hY(a,b){var s=b.b,r=s==null,q=r?null:s.a
a.selectedAddress=q
if(r)s=null
else s=A.hH(s.a,s.b).gu()
a.publicKey=s
s=b.a
r=A.F(s)
q=r.h("y<1,i>")
q=A.B(new A.y(s,r.h("i(1)").a(new A.ef()),q),!0,q.h("w.E"))
a.accounts=t.c.a(self.Object.freeze(q))
a.isConnected=t.B.a(a.publicKey)!=null},
hI(a){var s,r=a.a,q=a.$ti.h("4?"),p=t.j,o=t.S,n=J.Z(p.a(q.a(r.j(0,"signature"))),o),m=self,l=t.K
n=l.a(m.Uint8Array.from(A.N(n)))
s=J.Z(p.a(q.a(r.j(0,"signedMessage"))),o)
s=l.a(m.Uint8Array.from(A.N(s)))
return{signature:n,publicKey:A.hH(A.f(q.a(r.j(0,"signer"))),J.Z(p.a(q.a(r.j(0,"signerAddressBytes"))),o)).gu(),signedMessage:s}},
hJ(a){return B.a.a3(B.Y,new A.dv(a),new A.dw())},
js(a,b,c,d){switch(A.hJ(A.T(a.txType))){case B.E:return{signedTransaction:t.K.a(self.Uint8Array.from(A.N(c)))}
case B.x:a.addSignature(d.gu(),t.K.a(self.Uint8Array.from(A.N(b))))
return a}},
hZ(a){var s,r,q
try{s=t.m.a(a)
r=s
r.txType="web3"
r.serializedBytes=t.K.a(s.serialize({verifySignatures:!1}))
return r}catch(q){return null}},
hH(a,b){var s=self,r=t.K,q=r.a(s.Uint8Array.from(A.N(b)))
return new A.bk(a,q,new s.BN(r.a(q.slice())))},
h2(a){var s=A.f(a.j(0,"base58")),r=t.j,q=J.Z(r.a(a.j(0,"bytes")),t.S),p=t.N,o=J.Z(r.a(a.j(0,"chains")),p)
r=J.Z(r.a(a.j(0,"features")),p)
return new A.a1(s,q,A.a5(o,p),A.a5(r,p))},
hW(a){var s,r,q="defaultAddress",p=t.Q,o=J.c6(t.j.a(a.j(0,"accounts")),new A.dX(),p)
o=A.B(o,!0,o.$ti.h("w.E"))
s=a.j(0,q)==null?null:A.h2(t.b.a(a.j(0,q)))
r=A.hX(t.b.a(a.j(0,"connectInfo")))
return new A.dW(A.a5(o,p),s,r)},
hX(a){return new A.cG(A.f(a.j(0,"genesisBlock")),A.f(a.j(0,"name")))},
eh(a,b){var s=b==null?null:A.a5(b,t.N)
return new A.eg(s,a==null?null:A.a5(a,t.Q))},
ef:function ef(){},
aV:function aV(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
as:function as(a){this.b=a},
dv:function dv(a){this.a=a},
dw:function dw(){},
bk:function bk(a,b,c){this.a=a
this.b=b
this.c=c},
dt:function dt(a){this.a=a},
du:function du(a){this.a=a},
a1:function a1(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
ee:function ee(){},
dW:function dW(a,b,c){this.a=a
this.b=b
this.c=c},
dX:function dX(){},
dY:function dY(){},
cG:function cG(a,b){this.a=a
this.b=b},
ec:function ec(a){this.a=a},
ed:function ed(a){this.a=a},
eg:function eg(a,b){this.a=a
this.b=b},
ei:function ei(){},
ej:function ej(){},
ek:function ek(a,b,c){this.a=a
this.b=b
this.c=c},
el:function el(){},
bw:function bw(a){this.a=a},
eo:function eo(a){this.a=a},
ep:function ep(a){this.a=a},
h3:function h3(a,b){this.a=a
this.b=b},
cL:function cL(a){this.a=a},
eq:function eq(a){this.a=a},
er:function er(a){this.a=a},
i4(a){var s=A.ha(A.f(a.j(0,"net_version")),null),r=A.f(a.j(0,"fullNode")),q=A.f(a.j(0,"solidityNode"))
return new A.cN("0x"+s.a6(0,16),q,r)},
af:function af(a,b){this.a=a
this.b=b},
dx:function dx(a){this.a=a},
dy:function dy(a){this.a=a},
dz:function dz(a){this.a=a},
eE:function eE(a,b,c,d){var _=this
_.b=a
_.d=b
_.e=c
_.f=d},
eF:function eF(a){this.a=a},
eG:function eG(a){this.a=a},
eH:function eH(a){this.a=a},
h4:function h4(a,b){this.a=a
this.b=b},
cN:function cN(a,b,c){this.a=a
this.c=b
this.d=c},
eu:function eu(a){this.a=a},
ev:function ev(a){this.a=a},
fZ(a,b){return a},
jC(a){return a},
fT(a){var s,r,q,p,o
for(s=a.a,r=J.fD(s),q=a.$ti.y[1],p=0;p<r.gm(s);++p){o=q.a(r.j(s,p))
if(o<0||o>255)throw A.b(A.a9("Invalid bytes at index "+p+": "+A.z(o),null))}},
hS(a,b,c){var s,r,q=null
try{s=B.a.cA(a,b)
return s}catch(r){if(A.aH(r) instanceof A.b3){s=q
s=s==null?null:s.$0()
return s}else throw r}},
i8(){return new A.aN(u.b,-32602,"WEB3-5100","Transaction serialization failed")}},B={}
var w=[A,J,B]
var $={}
A.fX.prototype={}
J.ci.prototype={
U(a,b){return a===b},
gq(a){return A.cC(a)},
i(a){return"Instance of '"+A.dQ(a)+"'"},
gv(a){return A.aQ(A.hi(this))}}
J.cj.prototype={
i(a){return String(a)},
gq(a){return a?519018:218159},
gv(a){return A.aQ(t.y)},
$ip:1,
$iE:1}
J.bi.prototype={
U(a,b){return null==b},
i(a){return"null"},
gq(a){return 0},
$ip:1,
$iG:1}
J.bl.prototype={$ii:1}
J.av.prototype={
gq(a){return 0},
i(a){return String(a)}}
J.cB.prototype={}
J.bx.prototype={}
J.L.prototype={
i(a){var s=a[$.c4()]
if(s==null)return this.bH(a)
return"JavaScript function for "+J.bb(s)},
$iaK:1}
J.aY.prototype={
gq(a){return 0},
i(a){return String(a)}}
J.aZ.prototype={
gq(a){return 0},
i(a){return String(a)}}
J.m.prototype={
aA(a,b){return new A.K(a,A.F(a).h("@<1>").l(b).h("K<1,2>"))},
k(a,b){A.F(a).c.a(b)
a.$flags&1&&A.I(a,29)
a.push(b)},
G(a,b){var s
a.$flags&1&&A.I(a,"remove",1)
for(s=0;s<a.length;++s)if(J.fP(a[s],b)){a.splice(s,1)
return!0}return!1},
b_(a,b){var s
A.F(a).h("h<1>").a(b)
a.$flags&1&&A.I(a,"addAll",2)
if(Array.isArray(b)){this.bL(a,b)
return}for(s=J.ba(b);s.n();)a.push(s.gp())},
bL(a,b){var s,r
t.o.a(b)
s=b.length
if(s===0)return
if(a===b)throw A.b(A.aq(a))
for(r=0;r<s;++r)a.push(b[r])},
aB(a){a.$flags&1&&A.I(a,"clear","clear")
a.length=0},
a4(a,b,c){var s=A.F(a)
return new A.y(a,s.l(c).h("1(2)").a(b),s.h("@<1>").l(c).h("y<1,2>"))},
ah(a,b){var s,r=A.hO(a.length,"",!1,t.N)
for(s=0;s<a.length;++s)this.t(r,s,A.z(a[s]))
return r.join(b)},
a3(a,b,c){var s,r,q,p=A.F(a)
p.h("E(1)").a(b)
p.h("1()?").a(c)
s=a.length
for(r=0;r<s;++r){q=a[r]
if(A.iJ(b.$1(q)))return q
if(a.length!==s)throw A.b(A.aq(a))}if(c!=null)return c.$0()
throw A.b(A.jn())},
cA(a,b){return this.a3(a,b,null)},
F(a,b){if(!(b>=0&&b<a.length))return A.e(a,b)
return a[b]},
a8(a,b,c){var s=a.length
if(b>s)throw A.b(A.ax(b,0,s,"start",null))
if(c==null)c=s
else if(c<b||c>s)throw A.b(A.ax(c,b,s,"end",null))
if(b===c)return A.d([],A.F(a))
return A.d(a.slice(b,c),A.F(a))},
bF(a,b){return this.a8(a,b,null)},
by(a,b){var s
for(s=0;s<a.length;++s)if(J.fP(a[s],b))return!0
return!1},
i(a){return A.hF(a,"[","]")},
gA(a){return new J.bc(a,a.length,A.F(a).h("bc<1>"))},
gq(a){return A.cC(a)},
gm(a){return a.length},
j(a,b){if(!(b>=0&&b<a.length))throw A.b(A.fB(a,b))
return a[b]},
t(a,b,c){A.F(a).c.a(c)
a.$flags&2&&A.I(a)
if(!(b>=0&&b<a.length))throw A.b(A.fB(a,b))
a[b]=c},
$ik:1,
$ih:1,
$in:1}
J.dA.prototype={}
J.bc.prototype={
gp(){var s=this.d
return s==null?this.$ti.c.a(s):s},
n(){var s,r=this,q=r.a,p=q.length
if(r.b!==p){q=A.hq(q)
throw A.b(q)}s=r.c
if(s>=p){r.sbd(null)
return!1}r.sbd(q[s]);++r.c
return!0},
sbd(a){this.d=this.$ti.h("1?").a(a)},
$iaa:1}
J.bj.prototype={
ct(a){var s,r
if(a>=0){if(a<=2147483647){s=a|0
return a===s?s:s+1}}else if(a>=-2147483648)return a|0
r=Math.ceil(a)
if(isFinite(r))return r
throw A.b(A.cR(""+a+".ceil()"))},
a6(a,b){var s,r,q,p,o
if(b<2||b>36)throw A.b(A.ax(b,2,36,"radix",null))
s=a.toString(b)
r=s.length
q=r-1
if(!(q>=0))return A.e(s,q)
if(s.charCodeAt(q)!==41)return s
p=/^([\da-z]+)(?:\.([\da-z]+))?\(e\+(\d+)\)$/.exec(s)
if(p==null)A.a7(A.cR("Unexpected toString result: "+s))
r=p.length
if(1>=r)return A.e(p,1)
s=p[1]
if(3>=r)return A.e(p,3)
o=+p[3]
r=p[2]
if(r!=null){s+=r
o-=r.length}return s+B.m.ak("0",o)},
i(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gq(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
aj(a,b){var s=a%b
if(s===0)return 0
if(s>0)return s
return s+b},
bI(a,b){if((a|0)===a)if(b>=1)return a/b|0
return this.br(a,b)},
S(a,b){return(a|0)===a?a/b|0:this.br(a,b)},
br(a,b){var s=a/b
if(s>=-2147483648&&s<=2147483647)return s|0
if(s>0){if(s!==1/0)return Math.floor(s)}else if(s>-1/0)return Math.ceil(s)
throw A.b(A.cR("Result of truncating division is "+A.z(s)+": "+A.z(a)+" ~/ "+b))},
a7(a,b){if(b<0)throw A.b(A.c0(b))
return b>31?0:a<<b>>>0},
af(a,b){var s
if(a>0)s=this.bn(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
aX(a,b){if(0>b)throw A.b(A.c0(b))
return this.bn(a,b)},
bn(a,b){return b>31?0:a>>>b},
gv(a){return A.aQ(t.p)},
$iq:1,
$ib9:1}
J.bh.prototype={
gbw(a){var s,r=a<0?-a-1:a,q=r
for(s=32;q>=4294967296;){q=this.S(q,4294967296)
s+=32}return s-Math.clz32(q)},
gv(a){return A.aQ(t.S)},
$ip:1,
$ia:1}
J.ck.prototype={
gv(a){return A.aQ(t.i)},
$ip:1}
J.aW.prototype={
bG(a,b,c){return a.substring(b,A.jR(b,c,a.length))},
ak(a,b){var s,r
if(0>=b)return""
if(b===1||a.length===0)return a
if(b!==b>>>0)throw A.b(B.R)
for(s=a,r="";!0;){if((b&1)===1)r=s+r
b=b>>>1
if(b===0)break
s+=s}return r},
cJ(a,b,c){var s=b-a.length
if(s<=0)return a
return this.ak(c,s)+a},
i(a){return a},
gq(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
gv(a){return A.aQ(t.N)},
gm(a){return a.length},
$ip:1,
$ij:1}
A.az.prototype={
gA(a){return new A.be(J.ba(this.gag()),A.H(this).h("be<1,2>"))},
gm(a){return J.c5(this.gag())},
F(a,b){return A.H(this).y[1].a(J.hu(this.gag(),b))},
i(a){return J.bb(this.gag())}}
A.be.prototype={
n(){return this.a.n()},
gp(){return this.$ti.y[1].a(this.a.gp())},
$iaa:1}
A.aI.prototype={
gag(){return this.a}}
A.bE.prototype={$ik:1}
A.bC.prototype={
j(a,b){return this.$ti.y[1].a(J.j6(this.a,b))},
$ik:1,
$in:1}
A.K.prototype={
aA(a,b){return new A.K(this.a,this.$ti.h("@<1>").l(b).h("K<1,2>"))},
gag(){return this.a}}
A.aJ.prototype={
a2(a,b,c){return new A.aJ(this.a,this.$ti.h("@<1,2>").l(b).l(c).h("aJ<1,2,3,4>"))},
j(a,b){return this.$ti.h("4?").a(this.a.j(0,b))},
t(a,b,c){var s=this.$ti
s.y[2].a(b)
s.y[3].a(c)
this.a.t(0,s.c.a(b),s.y[1].a(c))},
G(a,b){return this.$ti.h("4?").a(this.a.G(0,b))},
Y(a,b){this.a.Y(0,new A.da(this,this.$ti.h("~(3,4)").a(b)))},
gZ(){var s=this.$ti
return A.hA(this.a.gZ(),s.c,s.y[2])},
gm(a){var s=this.a
return s.gm(s)}}
A.da.prototype={
$2(a,b){var s=this.a.$ti
s.c.a(a)
s.y[1].a(b)
this.b.$2(s.y[2].a(a),s.y[3].a(b))},
$S(){return this.a.$ti.h("~(1,2)")}}
A.b_.prototype={
i(a){return"LateInitializationError: "+this.a}}
A.dV.prototype={}
A.k.prototype={}
A.w.prototype={
gA(a){var s=this
return new A.aL(s,s.gm(s),A.H(s).h("aL<w.E>"))},
cH(a){var s,r,q=this,p=q.gm(q)
for(s=0,r="";s<p;++s){r+=A.z(q.F(0,s))
if(p!==q.gm(q))throw A.b(A.aq(q))}return r.charCodeAt(0)==0?r:r},
a4(a,b,c){var s=A.H(this)
return new A.y(this,s.l(c).h("1(w.E)").a(b),s.h("@<w.E>").l(c).h("y<1,2>"))}}
A.aL.prototype={
gp(){var s=this.d
return s==null?this.$ti.c.a(s):s},
n(){var s,r=this,q=r.a,p=J.fD(q),o=p.gm(q)
if(r.b!==o)throw A.b(A.aq(q))
s=r.c
if(s>=o){r.sa9(null)
return!1}r.sa9(p.F(q,s));++r.c
return!0},
sa9(a){this.d=this.$ti.h("1?").a(a)},
$iaa:1}
A.aM.prototype={
gA(a){var s=this.a
return new A.bn(s.gA(s),this.b,A.H(this).h("bn<1,2>"))},
gm(a){var s=this.a
return s.gm(s)},
F(a,b){var s=this.a
return this.b.$1(s.F(s,b))}}
A.bf.prototype={$ik:1}
A.bn.prototype={
n(){var s=this,r=s.b
if(r.n()){s.sa9(s.c.$1(r.gp()))
return!0}s.sa9(null)
return!1},
gp(){var s=this.a
return s==null?this.$ti.y[1].a(s):s},
sa9(a){this.a=this.$ti.h("2?").a(a)},
$iaa:1}
A.y.prototype={
gm(a){return J.c5(this.a)},
F(a,b){return this.b.$1(J.hu(this.a,b))}}
A.P.prototype={}
A.ay.prototype={
gm(a){return J.c5(this.a)},
F(a,b){var s=this.a,r=J.fD(s)
return r.F(s,r.gm(s)-1-b)}}
A.bT.prototype={}
A.eI.prototype={
I(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
if(p==null)return null
s=Object.create(null)
r=q.b
if(r!==-1)s.arguments=p[r+1]
r=q.c
if(r!==-1)s.argumentsExpr=p[r+1]
r=q.d
if(r!==-1)s.expr=p[r+1]
r=q.e
if(r!==-1)s.method=p[r+1]
r=q.f
if(r!==-1)s.receiver=p[r+1]
return s}}
A.bu.prototype={
i(a){return"Null check operator used on a null value"}}
A.cn.prototype={
i(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.cQ.prototype={
i(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.dO.prototype={
i(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.bg.prototype={}
A.bN.prototype={
i(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$iac:1}
A.ap.prototype={
i(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.iQ(r==null?"unknown":r)+"'"},
$iaK:1,
gcY(){return this},
$C:"$1",
$R:1,
$D:null}
A.c9.prototype={$C:"$0",$R:0}
A.ca.prototype={$C:"$2",$R:2}
A.cK.prototype={}
A.cH.prototype={
i(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.iQ(s)+"'"}}
A.aU.prototype={
U(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.aU))return!1
return this.$_target===b.$_target&&this.a===b.a},
gq(a){return(A.d8(this.a)^A.cC(this.$_target))>>>0},
i(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.dQ(this.a)+"'")}}
A.cY.prototype={
i(a){return"Reading static variable '"+this.a+"' during its initialization"}}
A.cE.prototype={
i(a){return"RuntimeError: "+this.a}}
A.cT.prototype={
i(a){return"Assertion failed: "+A.ce(this.a)}}
A.ag.prototype={
gm(a){return this.a},
gZ(){return new A.W(this,A.H(this).h("W<1>"))},
E(a){var s=this.cD(a)
return s},
cD(a){var s=this.d
if(s==null)return!1
return this.aE(s[this.aD(a)],a)>=0},
j(a,b){var s,r,q,p,o=null
if(typeof b=="string"){s=this.b
if(s==null)return o
r=s[b]
q=r==null?o:r.b
return q}else if(typeof b=="number"&&(b&0x3fffffff)===b){p=this.c
if(p==null)return o
r=p[b]
q=r==null?o:r.b
return q}else return this.cE(b)},
cE(a){var s,r,q=this.d
if(q==null)return null
s=q[this.aD(a)]
r=this.aE(s,a)
if(r<0)return null
return s[r].b},
t(a,b,c){var s,r,q=this,p=A.H(q)
p.c.a(b)
p.y[1].a(c)
if(typeof b=="string"){s=q.b
q.b5(s==null?q.b=q.aQ():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=q.c
q.b5(r==null?q.c=q.aQ():r,b,c)}else q.cG(b,c)},
cG(a,b){var s,r,q,p,o=this,n=A.H(o)
n.c.a(a)
n.y[1].a(b)
s=o.d
if(s==null)s=o.d=o.aQ()
r=o.aD(a)
q=s[r]
if(q==null)s[r]=[o.aR(a,b)]
else{p=o.aE(q,a)
if(p>=0)q[p].b=b
else q.push(o.aR(a,b))}},
G(a,b){var s=this
if(typeof b=="string")return s.bl(s.b,b)
else if(typeof b=="number"&&(b&0x3fffffff)===b)return s.bl(s.c,b)
else return s.cF(b)},
cF(a){var s,r,q,p,o=this,n=o.d
if(n==null)return null
s=o.aD(a)
r=n[s]
q=o.aE(r,a)
if(q<0)return null
p=r.splice(q,1)[0]
o.bt(p)
if(r.length===0)delete n[s]
return p.b},
Y(a,b){var s,r,q=this
A.H(q).h("~(1,2)").a(b)
s=q.e
r=q.r
for(;s!=null;){b.$2(s.a,s.b)
if(r!==q.r)throw A.b(A.aq(q))
s=s.c}},
b5(a,b,c){var s,r=A.H(this)
r.c.a(b)
r.y[1].a(c)
s=a[b]
if(s==null)a[b]=this.aR(b,c)
else s.b=c},
bl(a,b){var s
if(a==null)return null
s=a[b]
if(s==null)return null
this.bt(s)
delete a[b]
return s.b},
bh(){this.r=this.r+1&1073741823},
aR(a,b){var s=this,r=A.H(s),q=new A.dJ(r.c.a(a),r.y[1].a(b))
if(s.e==null)s.e=s.f=q
else{r=s.f
r.toString
q.d=r
s.f=r.c=q}++s.a
s.bh()
return q},
bt(a){var s=this,r=a.d,q=a.c
if(r==null)s.e=q
else r.c=q
if(q==null)s.f=r
else q.d=r;--s.a
s.bh()},
aD(a){return J.fQ(a)&1073741823},
aE(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.fP(a[r].a,b))return r
return-1},
i(a){return A.h0(this)},
aQ(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
$ihL:1}
A.dJ.prototype={}
A.W.prototype={
gm(a){return this.a.a},
gA(a){var s=this.a,r=new A.bm(s,s.r,this.$ti.h("bm<1>"))
r.c=s.e
return r}}
A.bm.prototype={
gp(){return this.d},
n(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.b(A.aq(q))
s=r.c
if(s==null){r.sb6(null)
return!1}else{r.sb6(s.a)
r.c=s.c
return!0}},
sb6(a){this.d=this.$ti.h("1?").a(a)},
$iaa:1}
A.fF.prototype={
$1(a){return this.a(a)},
$S:17}
A.fG.prototype={
$2(a,b){return this.a(a,b)},
$S:30}
A.fH.prototype={
$1(a){return this.a(A.f(a))},
$S:24}
A.cm.prototype={
i(a){return"RegExp/"+this.a+"/"+this.b.flags},
cz(a){var s=this.b.exec(a)
if(s==null)return null
return new A.fm(s)},
$ijS:1}
A.fm.prototype={}
A.f5.prototype={
D(){var s=this.b
if(s===this)throw A.b(new A.b_("Field '"+this.a+"' has not been initialized."))
return s}}
A.bo.prototype={
gv(a){return B.a3},
bu(a,b,c){var s=new Uint8Array(a,b,c)
return s},
$ip:1,
$ibo:1,
$ic8:1}
A.bs.prototype={
gcs(a){if(((a.$flags|0)&2)!==0)return new A.d4(a.buffer)
else return a.buffer}}
A.d4.prototype={
bu(a,b,c){var s=A.jB(this.a,b,c)
s.$flags=3
return s},
$ic8:1}
A.bp.prototype={
gv(a){return B.a4},
$ip:1,
$ifS:1}
A.b0.prototype={
gm(a){return a.length},
$iV:1}
A.bq.prototype={
j(a,b){A.aP(b,a,a.length)
return a[b]},
$ik:1,
$ih:1,
$in:1}
A.br.prototype={$ik:1,$ih:1,$in:1}
A.co.prototype={
gv(a){return B.a5},
$ip:1,
$idg:1}
A.cp.prototype={
gv(a){return B.a6},
$ip:1,
$idh:1}
A.cq.prototype={
gv(a){return B.a7},
j(a,b){A.aP(b,a,a.length)
return a[b]},
$ip:1,
$idj:1}
A.cr.prototype={
gv(a){return B.a8},
j(a,b){A.aP(b,a,a.length)
return a[b]},
$ip:1,
$idk:1}
A.cs.prototype={
gv(a){return B.a9},
j(a,b){A.aP(b,a,a.length)
return a[b]},
$ip:1,
$idl:1}
A.ct.prototype={
gv(a){return B.ab},
j(a,b){A.aP(b,a,a.length)
return a[b]},
$ip:1,
$ieM:1}
A.cu.prototype={
gv(a){return B.ac},
j(a,b){A.aP(b,a,a.length)
return a[b]},
$ip:1,
$ieN:1}
A.bt.prototype={
gv(a){return B.ad},
gm(a){return a.length},
j(a,b){A.aP(b,a,a.length)
return a[b]},
$ip:1,
$ieO:1}
A.cv.prototype={
gv(a){return B.ae},
gm(a){return a.length},
j(a,b){A.aP(b,a,a.length)
return a[b]},
$ip:1,
$ieP:1}
A.bJ.prototype={}
A.bK.prototype={}
A.bL.prototype={}
A.bM.prototype={}
A.a0.prototype={
h(a){return A.fr(v.typeUniverse,this,a)},
l(a){return A.kr(v.typeUniverse,this,a)}}
A.d_.prototype={}
A.fq.prototype={
i(a){return A.U(this.a,null)}}
A.cZ.prototype={
i(a){return this.a}}
A.bO.prototype={$iah:1}
A.f_.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:15}
A.eZ.prototype={
$1(a){var s,r
this.a.a=t.M.a(a)
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:25}
A.f0.prototype={
$0(){this.a.$0()},
$S:19}
A.f1.prototype={
$0(){this.a.$0()},
$S:19}
A.fo.prototype={
bK(a,b){if(self.setTimeout!=null)self.setTimeout(A.c1(new A.fp(this,b),0),a)
else throw A.b(A.cR("`setTimeout()` not found."))}}
A.fp.prototype={
$0(){this.b.$0()},
$S:0}
A.bA.prototype={
aC(a){var s,r=this,q=r.$ti
q.h("1/?").a(a)
if(a==null)a=q.c.a(a)
if(!r.b)r.a.b8(a)
else{s=r.a
if(q.h("ar<1>").b(a))s.b9(a)
else s.aJ(a)}},
b0(a,b){var s=this.a
if(this.b)s.ab(a,b)
else s.an(a,b)},
$idc:1}
A.ft.prototype={
$1(a){return this.a.$2(0,a)},
$S:12}
A.fu.prototype={
$2(a,b){this.a.$2(1,new A.bg(a,t.l.a(b)))},
$S:35}
A.fy.prototype={
$2(a,b){this.a(A.X(a),b)},
$S:27}
A.ad.prototype={
i(a){return A.z(this.a)},
$ir:1,
ga_(){return this.b}}
A.bD.prototype={
b0(a,b){var s,r=this.a
if((r.a&30)!==0)throw A.b(A.i0("Future already completed"))
s=A.kN(a,b)
r.an(s.a,s.b)},
bx(a){return this.b0(a,null)},
$idc:1}
A.aO.prototype={
aC(a){var s,r=this.$ti
r.h("1/?").a(a)
s=this.a
if((s.a&30)!==0)throw A.b(A.i0("Future already completed"))
s.b8(r.h("1/").a(a))}}
A.aj.prototype={
cI(a){if((this.c&15)!==6)return!0
return this.b.b.b3(t.bG.a(this.d),a.a,t.y,t.K)},
cB(a){var s,r=this,q=r.e,p=null,o=t.z,n=t.K,m=a.a,l=r.b.b
if(t.U.b(q))p=l.cM(q,m,a.b,o,n,t.l)
else p=l.b3(t.v.a(q),m,o,n)
try{o=r.$ti.h("2/").a(p)
return o}catch(s){if(t.b7.b(A.aH(s))){if((r.c&1)!==0)throw A.b(A.a9("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.b(A.a9("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.C.prototype={
bm(a){this.a=this.a&1|4
this.c=a},
aF(a,b,c){var s,r,q,p=this.$ti
p.l(c).h("1/(2)").a(a)
s=$.v
if(s===B.c){if(b!=null&&!t.U.b(b)&&!t.v.b(b))throw A.b(A.hv(b,"onError",u.c))}else{c.h("@<0/>").l(p.c).h("1(2)").a(a)
if(b!=null)b=A.iD(b,s)}r=new A.C(s,c.h("C<0>"))
q=b==null?1:3
this.am(new A.aj(r,q,a,b,p.h("@<1>").l(c).h("aj<1,2>")))
return r},
a5(a,b){return this.aF(a,null,b)},
bs(a,b,c){var s,r=this.$ti
r.l(c).h("1/(2)").a(a)
s=new A.C($.v,c.h("C<0>"))
this.am(new A.aj(s,19,a,b,r.h("@<1>").l(c).h("aj<1,2>")))
return s},
c7(a){this.a=this.a&1|16
this.c=a},
ao(a){this.a=a.a&30|this.a&1
this.c=a.c},
am(a){var s,r=this,q=r.a
if(q<=3){a.a=t.F.a(r.c)
r.c=a}else{if((q&4)!==0){s=t.d.a(r.c)
if((s.a&24)===0){s.am(a)
return}r.ao(s)}A.b6(null,null,r.b,t.M.a(new A.f8(r,a)))}},
aT(a){var s,r,q,p,o,n,m=this,l={}
l.a=a
if(a==null)return
s=m.a
if(s<=3){r=t.F.a(m.c)
m.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){n=t.d.a(m.c)
if((n.a&24)===0){n.aT(a)
return}m.ao(n)}l.a=m.av(a)
A.b6(null,null,m.b,t.M.a(new A.ff(l,m)))}},
aU(){var s=t.F.a(this.c)
this.c=null
return this.av(s)},
av(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
bP(a){var s,r,q,p=this
p.a^=2
try{a.aF(new A.fc(p),new A.fd(p),t.P)}catch(q){s=A.aH(q)
r=A.aF(q)
A.lx(new A.fe(p,s,r))}},
aJ(a){var s,r=this
r.$ti.c.a(a)
s=r.aU()
r.a=8
r.c=a
A.bF(r,s)},
ab(a,b){var s
t.l.a(b)
s=this.aU()
this.c7(new A.ad(a,b))
A.bF(this,s)},
b8(a){var s=this.$ti
s.h("1/").a(a)
if(s.h("ar<1>").b(a)){this.b9(a)
return}this.bM(a)},
bM(a){var s=this
s.$ti.c.a(a)
s.a^=2
A.b6(null,null,s.b,t.M.a(new A.fa(s,a)))},
b9(a){var s=this.$ti
s.h("ar<1>").a(a)
if(s.b(a)){A.ka(a,this)
return}this.bP(a)},
an(a,b){this.a^=2
A.b6(null,null,this.b,t.M.a(new A.f9(this,a,b)))},
$iar:1}
A.f8.prototype={
$0(){A.bF(this.a,this.b)},
$S:0}
A.ff.prototype={
$0(){A.bF(this.b,this.a.a)},
$S:0}
A.fc.prototype={
$1(a){var s,r,q,p=this.a
p.a^=2
try{p.aJ(p.$ti.c.a(a))}catch(q){s=A.aH(q)
r=A.aF(q)
p.ab(s,r)}},
$S:15}
A.fd.prototype={
$2(a,b){this.a.ab(t.K.a(a),t.l.a(b))},
$S:28}
A.fe.prototype={
$0(){this.a.ab(this.b,this.c)},
$S:0}
A.fb.prototype={
$0(){A.ij(this.a.a,this.b)},
$S:0}
A.fa.prototype={
$0(){this.a.aJ(this.b)},
$S:0}
A.f9.prototype={
$0(){this.a.ab(this.b,this.c)},
$S:0}
A.fi.prototype={
$0(){var s,r,q,p,o,n,m,l=this,k=null
try{q=l.a.a
k=q.b.b.cL(t.cW.a(q.d),t.z)}catch(p){s=A.aH(p)
r=A.aF(p)
if(l.c&&t.n.a(l.b.a.c).a===s){q=l.a
q.c=t.n.a(l.b.a.c)}else{q=s
o=r
if(o==null)o=A.fR(q)
n=l.a
n.c=new A.ad(q,o)
q=n}q.b=!0
return}if(k instanceof A.C&&(k.a&24)!==0){if((k.a&16)!==0){q=l.a
q.c=t.n.a(k.c)
q.b=!0}return}if(k instanceof A.C){m=l.b.a
q=l.a
q.c=k.a5(new A.fj(m),t.z)
q.b=!1}},
$S:0}
A.fj.prototype={
$1(a){return this.a},
$S:31}
A.fh.prototype={
$0(){var s,r,q,p,o,n,m,l
try{q=this.a
p=q.a
o=p.$ti
n=o.c
m=n.a(this.b)
q.c=p.b.b.b3(o.h("2/(1)").a(p.d),m,o.h("2/"),n)}catch(l){s=A.aH(l)
r=A.aF(l)
q=s
p=r
if(p==null)p=A.fR(q)
o=this.a
o.c=new A.ad(q,p)
o.b=!0}},
$S:0}
A.fg.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=t.n.a(l.a.a.c)
p=l.b
if(p.a.cI(s)&&p.a.e!=null){p.c=p.a.cB(s)
p.b=!1}}catch(o){r=A.aH(o)
q=A.aF(o)
p=t.n.a(l.a.a.c)
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.fR(p)
m=l.b
m.c=new A.ad(p,n)
p=m}p.b=!0}},
$S:0}
A.cU.prototype={}
A.d1.prototype={}
A.bS.prototype={$ii9:1}
A.fx.prototype={
$0(){A.jm(this.a,this.b)},
$S:0}
A.d0.prototype={
cN(a){var s,r,q
t.M.a(a)
try{if(B.c===$.v){a.$0()
return}A.iE(null,null,this,a,t.H)}catch(q){s=A.aH(q)
r=A.aF(q)
A.hk(t.K.a(s),t.l.a(r))}},
bv(a){return new A.fn(this,t.M.a(a))},
cL(a,b){b.h("0()").a(a)
if($.v===B.c)return a.$0()
return A.iE(null,null,this,a,b)},
b3(a,b,c,d){c.h("@<0>").l(d).h("1(2)").a(a)
d.a(b)
if($.v===B.c)return a.$1(b)
return A.l1(null,null,this,a,b,c,d)},
cM(a,b,c,d,e,f){d.h("@<0>").l(e).l(f).h("1(2,3)").a(a)
e.a(b)
f.a(c)
if($.v===B.c)return a.$2(b,c)
return A.l0(null,null,this,a,b,c,d,e,f)},
bz(a,b,c,d){return b.h("@<0>").l(c).l(d).h("1(2,3)").a(a)}}
A.fn.prototype={
$0(){return this.a.cN(this.b)},
$S:0}
A.bG.prototype={
gm(a){return this.a},
gZ(){return new A.bH(this,this.$ti.h("bH<1>"))},
E(a){var s,r
if(typeof a=="string"&&a!=="__proto__"){s=this.b
return s==null?!1:s[a]!=null}else if(typeof a=="number"&&(a&1073741823)===a){r=this.c
return r==null?!1:r[a]!=null}else return this.bS(a)},
bS(a){var s=this.d
if(s==null)return!1
return this.ap(this.bg(s,a),a)>=0},
j(a,b){var s,r,q
if(typeof b=="string"&&b!=="__proto__"){s=this.b
r=s==null?null:A.hb(s,b)
return r}else if(typeof b=="number"&&(b&1073741823)===b){q=this.c
r=q==null?null:A.hb(q,b)
return r}else return this.bY(b)},
bY(a){var s,r,q=this.d
if(q==null)return null
s=this.bg(q,a)
r=this.ap(s,a)
return r<0?null:s[r+1]},
t(a,b,c){var s,r,q,p,o,n,m=this,l=m.$ti
l.c.a(b)
l.y[1].a(c)
if(typeof b=="string"&&b!=="__proto__"){s=m.b
m.b7(s==null?m.b=A.hc():s,b,c)}else if(typeof b=="number"&&(b&1073741823)===b){r=m.c
m.b7(r==null?m.c=A.hc():r,b,c)}else{q=m.d
if(q==null)q=m.d=A.hc()
p=A.d8(b)&1073741823
o=q[p]
if(o==null){A.hd(q,p,[b,c]);++m.a
m.e=null}else{n=m.ap(o,b)
if(n>=0)o[n+1]=c
else{o.push(b,c);++m.a
m.e=null}}}},
G(a,b){var s=this
if(typeof b=="string"&&b!=="__proto__")return s.bb(s.b,b)
else if(typeof b=="number"&&(b&1073741823)===b)return s.bb(s.c,b)
else return s.c5(b)},
c5(a){var s,r,q,p,o=this,n=o.d
if(n==null)return null
s=A.d8(a)&1073741823
r=n[s]
q=o.ap(r,a)
if(q<0)return null;--o.a
o.e=null
p=r.splice(q,2)[1]
if(0===r.length)delete n[s]
return p},
Y(a,b){var s,r,q,p,o,n,m=this,l=m.$ti
l.h("~(1,2)").a(b)
s=m.bc()
for(r=s.length,q=l.c,l=l.y[1],p=0;p<r;++p){o=s[p]
q.a(o)
n=m.j(0,o)
b.$2(o,n==null?l.a(n):n)
if(s!==m.e)throw A.b(A.aq(m))}},
bc(){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.e
if(h!=null)return h
h=A.hO(i.a,null,!1,t.z)
s=i.b
r=0
if(s!=null){q=Object.getOwnPropertyNames(s)
p=q.length
for(o=0;o<p;++o){h[r]=q[o];++r}}n=i.c
if(n!=null){q=Object.getOwnPropertyNames(n)
p=q.length
for(o=0;o<p;++o){h[r]=+q[o];++r}}m=i.d
if(m!=null){q=Object.getOwnPropertyNames(m)
p=q.length
for(o=0;o<p;++o){l=m[q[o]]
k=l.length
for(j=0;j<k;j+=2){h[r]=l[j];++r}}}return i.e=h},
b7(a,b,c){var s=this.$ti
s.c.a(b)
s.y[1].a(c)
if(a[b]==null){++this.a
this.e=null}A.hd(a,b,c)},
bb(a,b){var s
if(a!=null&&a[b]!=null){s=this.$ti.y[1].a(A.hb(a,b))
delete a[b];--this.a
this.e=null
return s}else return null},
bg(a,b){return a[A.d8(b)&1073741823]}}
A.b4.prototype={
ap(a,b){var s,r,q
if(a==null)return-1
s=a.length
for(r=0;r<s;r+=2){q=a[r]
if(q==null?b==null:q===b)return r}return-1}}
A.bH.prototype={
gm(a){return this.a.a},
gA(a){var s=this.a
return new A.bI(s,s.bc(),this.$ti.h("bI<1>"))}}
A.bI.prototype={
gp(){var s=this.d
return s==null?this.$ti.c.a(s):s},
n(){var s=this,r=s.b,q=s.c,p=s.a
if(r!==p.e)throw A.b(A.aq(p))
else if(q>=r.length){s.sba(null)
return!1}else{s.sba(r[q])
s.c=q+1
return!0}},
sba(a){this.d=this.$ti.h("1?").a(a)},
$iaa:1}
A.dK.prototype={
$2(a,b){this.a.t(0,this.b.a(a),this.c.a(b))},
$S:16}
A.o.prototype={
gA(a){return new A.aL(a,this.gm(a),A.aT(a).h("aL<o.E>"))},
F(a,b){return this.j(a,b)},
a4(a,b,c){var s=A.aT(a)
return new A.y(a,s.l(c).h("1(o.E)").a(b),s.h("@<o.E>").l(c).h("y<1,2>"))},
aA(a,b){return new A.K(a,A.aT(a).h("@<o.E>").l(b).h("K<1,2>"))},
i(a){return A.hF(a,"[","]")}}
A.x.prototype={
a2(a,b,c){return new A.aJ(this,A.H(this).h("@<x.K,x.V>").l(b).l(c).h("aJ<1,2,3,4>"))},
Y(a,b){var s,r,q,p=A.H(this)
p.h("~(x.K,x.V)").a(b)
for(s=this.gZ(),s=s.gA(s),p=p.h("x.V");s.n();){r=s.gp()
q=this.j(0,r)
b.$2(r,q==null?p.a(q):q)}},
bA(a,b){var s,r,q,p,o,n=this,m=A.H(n)
m.h("E(x.K,x.V)").a(b)
s=A.d([],m.h("m<x.K>"))
for(r=n.gZ(),r=r.gA(r),m=m.h("x.V");r.n();){q=r.gp()
p=n.j(0,q)
if(A.iJ(b.$2(q,p==null?m.a(p):p)))B.a.k(s,q)}for(m=s.length,o=0;o<s.length;s.length===m||(0,A.hq)(s),++o)n.G(0,s[o])},
gm(a){var s=this.gZ()
return s.gm(s)},
i(a){return A.h0(this)},
$iS:1}
A.dM.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.z(a)
s=r.a+=s
r.a=s+": "
s=A.z(b)
r.a+=s},
$S:36}
A.M.prototype={
K(a){var s,r,q=this,p=q.c
if(p===0)return q
s=!q.a
r=q.b
p=A.a3(p,r)
return new A.M(p===0?!1:s,r,p)},
bW(a){var s,r,q,p,o,n,m,l,k=this,j=k.c
if(j===0)return $.ao()
s=j-a
if(s<=0)return k.a?$.ht():$.ao()
r=k.b
q=new Uint16Array(s)
for(p=r.length,o=a;o<j;++o){n=o-a
if(!(o>=0&&o<p))return A.e(r,o)
m=r[o]
if(!(n<s))return A.e(q,n)
q[n]=m}n=k.a
m=A.a3(s,q)
l=new A.M(m===0?!1:n,q,m)
if(n)for(o=0;o<a;++o){if(!(o<p))return A.e(r,o)
if(r[o]!==0)return l.aH(0,$.d9())}return l},
bE(a,b){var s,r,q,p,o,n,m,l,k,j=this
if(b<0)throw A.b(A.a9("shift-amount must be posititve "+b,null))
s=j.c
if(s===0)return j
r=B.b.S(b,16)
q=B.b.aj(b,16)
if(q===0)return j.bW(r)
p=s-r
if(p<=0)return j.a?$.ht():$.ao()
o=j.b
n=new Uint16Array(p)
A.k8(o,s,b,n)
s=j.a
m=A.a3(p,n)
l=new A.M(m===0?!1:s,n,m)
if(s){s=o.length
if(!(r>=0&&r<s))return A.e(o,r)
if((o[r]&B.b.a7(1,q)-1)>>>0!==0)return l.aH(0,$.d9())
for(k=0;k<r;++k){if(!(k<s))return A.e(o,k)
if(o[k]!==0)return l.aH(0,$.d9())}}return l},
cu(a,b){var s,r=this.a
if(r===b.a){s=A.f2(this.b,this.c,b.b,b.c)
return r?0-s:s}return r?-1:1},
aI(a,b){var s,r,q,p=this,o=p.c,n=a.c
if(o<n)return a.aI(p,b)
if(o===0)return $.ao()
if(n===0)return p.a===b?p:p.K(0)
s=o+1
r=new Uint16Array(s)
A.k3(p.b,o,a.b,n,r)
q=A.a3(s,r)
return new A.M(q===0?!1:b,r,q)},
al(a,b){var s,r,q,p=this,o=p.c
if(o===0)return $.ao()
s=a.c
if(s===0)return p.a===b?p:p.K(0)
r=new Uint16Array(o)
A.cW(p.b,o,a.b,s,r)
q=A.a3(o,r)
return new A.M(q===0?!1:b,r,q)},
bB(a,b){var s,r,q=this,p=q.c
if(p===0)return b
s=b.c
if(s===0)return q
r=q.a
if(r===b.a)return q.aI(b,r)
if(A.f2(q.b,p,b.b,s)>=0)return q.al(b,r)
return b.al(q,!r)},
aH(a,b){var s,r,q=this,p=q.c
if(p===0)return b.K(0)
s=b.c
if(s===0)return q
r=q.a
if(r!==b.a)return q.aI(b,r)
if(A.f2(q.b,p,b.b,s)>=0)return q.al(b,r)
return b.al(q,!r)},
ak(a,b){var s,r,q,p,o,n,m,l=this.c,k=b.c
if(l===0||k===0)return $.ao()
s=l+k
r=this.b
q=b.b
p=new Uint16Array(s)
for(o=q.length,n=0;n<k;){if(!(n<o))return A.e(q,n)
A.ih(q[n],r,0,p,n,l);++n}o=this.a!==b.a
m=A.a3(s,p)
return new A.M(m===0?!1:o,p,m)},
be(a){var s,r,q,p
if(this.c<a.c)return $.ao()
this.bf(a)
s=$.h6.D()-$.bB.D()
r=A.h8($.h5.D(),$.bB.D(),$.h6.D(),s)
q=A.a3(s,r)
p=new A.M(!1,r,q)
return this.a!==a.a&&q>0?p.K(0):p},
bk(a){var s,r,q,p=this
if(p.c<a.c)return p
p.bf(a)
s=A.h8($.h5.D(),0,$.bB.D(),$.bB.D())
r=A.a3($.bB.D(),s)
q=new A.M(!1,s,r)
if($.h7.D()>0)q=q.bE(0,$.h7.D())
return p.a&&q.c>0?q.K(0):q},
bf(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b=c.c
if(b===$.id&&a.c===$.ig&&c.b===$.ic&&a.b===$.ie)return
s=a.b
r=a.c
q=r-1
if(!(q>=0&&q<s.length))return A.e(s,q)
p=16-B.b.gbw(s[q])
if(p>0){o=new Uint16Array(r+5)
n=A.ib(s,r,p,o)
m=new Uint16Array(b+5)
l=A.ib(c.b,b,p,m)}else{m=A.h8(c.b,0,b,b+2)
n=r
o=s
l=b}q=n-1
if(!(q>=0&&q<o.length))return A.e(o,q)
k=o[q]
j=l-n
i=new Uint16Array(l)
h=A.h9(o,n,j,i)
g=l+1
q=m.$flags|0
if(A.f2(m,l,i,h)>=0){q&2&&A.I(m)
if(!(l>=0&&l<m.length))return A.e(m,l)
m[l]=1
A.cW(m,g,i,h,m)}else{q&2&&A.I(m)
if(!(l>=0&&l<m.length))return A.e(m,l)
m[l]=0}q=n+2
f=new Uint16Array(q)
if(!(n>=0&&n<q))return A.e(f,n)
f[n]=1
A.cW(f,n+1,o,n,f)
e=l-1
for(q=m.length;j>0;){d=A.k4(k,m,e);--j
A.ih(d,f,0,m,j,n)
if(!(e>=0&&e<q))return A.e(m,e)
if(m[e]<d){h=A.h9(f,n,j,i)
A.cW(m,g,i,h,m)
for(;--d,m[e]<d;)A.cW(m,g,i,h,m)}--e}$.ic=c.b
$.id=b
$.ie=s
$.ig=r
$.h5.b=m
$.h6.b=g
$.bB.b=n
$.h7.b=p},
gq(a){var s,r,q,p,o=new A.f3(),n=this.c
if(n===0)return 6707
s=this.a?83585:429689
for(r=this.b,q=r.length,p=0;p<n;++p){if(!(p<q))return A.e(r,p)
s=o.$2(s,r[p])}return new A.f4().$1(s)},
U(a,b){if(b==null)return!1
return b instanceof A.M&&this.cu(0,b)===0},
cT(a){var s,r,q,p
for(s=this.c-1,r=this.b,q=r.length,p=0;s>=0;--s){if(!(s<q))return A.e(r,s)
p=p*65536+r[s]}return this.a?-p:p},
i(a){var s,r,q,p,o,n=this,m=n.c
if(m===0)return"0"
if(m===1){if(n.a){m=n.b
if(0>=m.length)return A.e(m,0)
return B.b.i(-m[0])}m=n.b
if(0>=m.length)return A.e(m,0)
return B.b.i(m[0])}s=A.d([],t.s)
m=n.a
r=m?n.K(0):n
for(;r.c>1;){q=$.hs()
if(q.c===0)A.a7(B.B)
p=r.bk(q).i(0)
B.a.k(s,p)
o=p.length
if(o===1)B.a.k(s,"000")
if(o===2)B.a.k(s,"00")
if(o===3)B.a.k(s,"0")
r=r.be(q)}q=r.b
if(0>=q.length)return A.e(q,0)
B.a.k(s,B.b.i(q[0]))
if(m)B.a.k(s,"-")
return new A.ay(s,t.bd).cH(0)},
aY(a){if(a<10)return 48+a
return 97+a-10},
a6(a,b){var s,r,q,p,o,n,m,l=this
if(b<2||b>36)throw A.b(A.ax(b,2,36,null,null))
s=l.c
if(s===0)return"0"
if(s===1){s=l.b
if(0>=s.length)return A.e(s,0)
r=B.b.a6(s[0],b)
if(l.a)return"-"+r
return r}if(b===16)return l.cn()
q=A.cV(b)
p=A.d([],t.t)
s=l.a
o=s?l.K(0):l
for(n=q.c===0;o.c!==0;){if(n)A.a7(B.B)
m=o.bk(q).cT(0)
o=o.be(q)
B.a.k(p,l.aY(m))}r=A.i2(new A.ay(p,t.w))
if(s)return"-"+r
return r},
cn(){var s,r,q,p,o,n,m,l=this,k=A.d([],t.t)
for(s=l.c-1,r=l.b,q=r.length,p=0;p<s;++p){if(!(p<q))return A.e(r,p)
o=r[p]
for(n=0;n<4;++n){B.a.k(k,l.aY(o&15))
o=o>>>4}}if(!(s>=0&&s<q))return A.e(r,s)
m=r[s]
for(;m!==0;){B.a.k(k,l.aY(m&15))
m=m>>>4}if(l.a)B.a.k(k,45)
return A.i2(new A.ay(k,t.w))},
$ijb:1}
A.f3.prototype={
$2(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
$S:37}
A.f4.prototype={
$1(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
$S:20}
A.cc.prototype={
U(a,b){var s
if(b==null)return!1
s=!1
if(b instanceof A.cc)if(this.a===b.a)s=this.b===b.b
return s},
gq(a){return A.jD(this.a,this.b)},
i(a){var s=this,r=A.jj(A.jM(s)),q=A.cd(A.jK(s)),p=A.cd(A.jG(s)),o=A.cd(A.jH(s)),n=A.cd(A.jJ(s)),m=A.cd(A.jL(s)),l=A.hC(A.jI(s)),k=s.b,j=k===0?"":A.hC(k)
return r+"-"+q+"-"+p+" "+o+":"+n+":"+m+"."+l+j+"Z"}}
A.f6.prototype={
i(a){return this.ad()}}
A.r.prototype={
ga_(){return A.jF(this)}}
A.bd.prototype={
i(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.ce(s)
return"Assertion failed"}}
A.ah.prototype={}
A.a4.prototype={
gaP(){return"Invalid argument"+(!this.a?"(s)":"")},
gaO(){return""},
i(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+p,n=s.gaP()+q+o
if(!s.a)return n
return n+s.gaO()+": "+A.ce(s.gb1())},
gb1(){return this.b}}
A.b2.prototype={
gb1(){return A.kv(this.b)},
gaP(){return"RangeError"},
gaO(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.z(q):""
else if(q==null)s=": Not greater than or equal to "+A.z(r)
else if(q>r)s=": Not in inclusive range "+A.z(r)+".."+A.z(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.z(r)
return s}}
A.cg.prototype={
gb1(){return A.X(this.b)},
gaP(){return"RangeError"},
gaO(){if(A.X(this.b)<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gm(a){return this.f}}
A.by.prototype={
i(a){return"Unsupported operation: "+this.a}}
A.cP.prototype={
i(a){return"UnimplementedError: "+this.a}}
A.b3.prototype={
i(a){return"Bad state: "+this.a}}
A.cb.prototype={
i(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.ce(s)+"."}}
A.cw.prototype={
i(a){return"Out of Memory"},
ga_(){return null},
$ir:1}
A.bv.prototype={
i(a){return"Stack Overflow"},
ga_(){return null},
$ir:1}
A.f7.prototype={
i(a){return"Exception: "+this.a}}
A.di.prototype={
i(a){var s=this.a,r=""!==s?"FormatException: "+s:"FormatException",q=this.b
if(q.length>78)q=B.m.bG(q,0,75)+"..."
return r+"\n"+q}}
A.ch.prototype={
ga_(){return null},
i(a){return"IntegerDivisionByZeroException"},
$ir:1}
A.h.prototype={
aA(a,b){return A.hA(this,A.H(this).h("h.E"),b)},
a4(a,b,c){var s=A.H(this)
return A.jA(this,s.l(c).h("1(h.E)").a(b),s.h("h.E"),c)},
gm(a){var s,r=this.gA(this)
for(s=0;r.n();)++s
return s},
F(a,b){var s,r
A.hT(b,"index")
s=this.gA(this)
for(r=b;s.n();){if(r===0)return s.gp();--r}throw A.b(A.hE(b,b-r,this,"index"))},
i(a){return A.jo(this,"(",")")}}
A.G.prototype={
gq(a){return A.c.prototype.gq.call(this,0)},
i(a){return"null"}}
A.c.prototype={$ic:1,
U(a,b){return this===b},
gq(a){return A.cC(this)},
i(a){return"Instance of '"+A.dQ(this)+"'"},
gv(a){return A.lj(this)},
toString(){return this.i(this)}}
A.d2.prototype={
i(a){return""},
$iac:1}
A.cJ.prototype={
gm(a){return this.a.length},
i(a){var s=this.a
return s.charCodeAt(0)==0?s:s}}
A.fJ.prototype={
$1(a){var s,r,q,p
if(A.iC(a))return a
s=this.a
if(s.E(a))return s.j(0,a)
if(a instanceof A.x){r={}
s.t(0,a,r)
for(s=a.gZ(),s=s.gA(s);s.n();){q=s.gp()
r[q]=this.$1(a.j(0,q))}return r}else if(t.bU.b(a)){p=[]
s.t(0,a,p)
B.a.b_(p,J.c6(a,this,t.z))
return p}else return a},
$S:9}
A.fM.prototype={
$1(a){return this.a.aC(this.b.h("0/?").a(a))},
$S:12}
A.fN.prototype={
$1(a){if(a==null)return this.a.bx(new A.dN(a===undefined))
return this.a.bx(a)},
$S:12}
A.fA.prototype={
$1(a){var s,r,q,p,o,n,m,l,k,j,i,h
if(A.iB(a))return a
s=this.a
a.toString
if(s.E(a))return s.j(0,a)
if(a instanceof Date){r=a.getTime()
if(r<-864e13||r>864e13)A.a7(A.ax(r,-864e13,864e13,"millisecondsSinceEpoch",null))
A.fz(!0,"isUtc",t.y)
return new A.cc(r,0,!0)}if(a instanceof RegExp)throw A.b(A.a9("structured clone of RegExp",null))
if(typeof Promise!="undefined"&&a instanceof Promise)return A.lv(a,t.X)
q=Object.getPrototypeOf(a)
if(q===Object.prototype||q===null){p=t.X
o=A.hM(p,p)
s.t(0,a,o)
n=Object.keys(a)
m=[]
for(s=J.aS(n),p=s.gA(n);p.n();)m.push(A.am(p.gp()))
for(l=0;l<s.gm(n);++l){k=s.j(n,l)
if(!(l<m.length))return A.e(m,l)
j=m[l]
if(k!=null)o.t(0,j,this.$1(a[k]))}return o}if(a instanceof Array){i=a
o=[]
s.t(0,a,o)
h=A.X(a.length)
for(s=J.aS(i),l=0;l<h;++l)o.push(this.$1(s.j(i,l)))
return o}return a},
$S:9}
A.dN.prototype={
i(a){return"Promise was rejected with a value of `"+(this.a?"undefined":"null")+"`."}}
A.fk.prototype={
bJ(){var s=self.crypto
if(s!=null)if(s.getRandomValues!=null)return
throw A.b(A.cR("No source of cryptographically secure random numbers available."))},
b2(a){var s,r,q,p,o,n,m,l,k=null
if(a<=0||a>4294967296)throw A.b(new A.b2(k,k,!1,k,k,"max must be in range 0 < max \u2264 2^32, was "+a))
if(a>255)if(a>65535)s=a>16777215?4:3
else s=2
else s=1
r=this.a
r.$flags&2&&A.I(r,11)
r.setUint32(0,0,!1)
q=4-s
p=A.X(Math.pow(256,s))
for(o=a-1,n=(a&o)===0;!0;){crypto.getRandomValues(J.j7(B.a2.gcs(r),q,s))
m=r.getUint32(0,!1)
if(n)return(m&o)>>>0
l=m%a
if(m-l+a<p)return l}}}
A.eK.prototype={
$1(a){var s
if(a===6)return this.a.b2(16)&15|64
else{s=this.a
if(a===8)return s.b2(4)&3|8
else return s.b2(256)}},
$S:20}
A.eL.prototype={
$1(a){return B.m.cJ(B.b.a6(A.X(a),16),2,"0")},
$S:48}
A.dL.prototype={
$1(a){return A.f(a)},
$S:8}
A.db.prototype={}
A.dI.prototype={}
A.aN.prototype={
H(){var s=this
return A.u(["message",s.a,"code",s.b,"walletCode",s.c,"data",s.d],t.N,t.z)},
cW(){var s=this
return new A.cS(s.a,s.b,s.c,s.d)},
i(a){return this.a}}
A.cS.prototype={
H(){var s=this,r=A.u(["message",s.a,"code",s.b,"walletCode",s.c,"data",s.d],t.N,t.z)
r.bA(0,new A.eV())
return r}}
A.eV.prototype={
$2(a,b){A.f(a)
return b==null},
$S:18}
A.eW.prototype={}
A.d5.prototype={}
A.d6.prototype={}
A.eX.prototype={}
A.a6.prototype={}
A.eY.prototype={
$1(a){var s
t.k.a(a)
s=this.a
return a.b===s||B.a.by(a.c,s)},
$S:47}
A.cA.prototype={}
A.O.prototype={
bD(a,b,c,d){var s=t.K
s.a(a)
s.a(b)
return!1},
bC(a,b){t.K.a(a)
return self.Reflect.get(a,b,null)}}
A.dd.prototype={
$1(a){var s,r=t.m
r.a(a)
s=self
r.a(s.window).dispatchEvent(this.a)
r.a(s.window).removeEventListener("eip6963:requestProvider",A.A(this))},
$S:10}
A.fU.prototype={
i(a){return"EthereumAccountsChanged"+A.u(["accounts",this.a,"defaultAddress",this.b],t.N,t.z).i(0)}}
A.cD.prototype={
gb4(){return new A.dS(this).$0()},
i(a){var s=t.N
return"ProviderConnectInfo"+A.u(["chainId",this.a],s,s).i(0)}}
A.dR.prototype={
$0(){return this.a.a},
$S:1}
A.dS.prototype={
$0(){var s,r=this.a,q=t.m,p=q.a(self),o=q.a(p.Object),n=q.a(o.create.apply(o,[null]))
n.toString=A.l(r.gB(r))
o=q.a(p.Object)
s=q.a(o.create.apply(o,[null]))
s.get=A.l(new A.dR(r))
p=q.a(p.Object)
p.defineProperty.apply(p,[n,"chainId",s])
return n},
$S:2}
A.dD.prototype={
$0(){return"MRT: "+this.a.a},
$S:1}
A.dB.prototype={
$2(a,b){A.f(a)
return b==null},
$S:18}
A.dC.prototype={
$0(){return A.h0(this.a)},
$S:1}
A.eU.prototype={
$2(a,b){var s,r,q,p=t.g
p.a(a)
p.a(b)
p=this.a.aF(new A.eR(a),new A.eS(b),t.X)
s=new A.eT(b,a)
r=p.$ti
q=$.v
if(q!==B.c)s=A.iD(s,q)
p.am(new A.aj(new A.C(q,r),2,null,s,r.h("aj<1,1>")))},
$S:26}
A.eR.prototype={
$1(a){var s=this.a
s.call(s,a)
return a},
$S:9}
A.eS.prototype={
$2(a,b){var s
t.K.a(a)
a.stack=t.l.a(b).i(0)
s=this.a
s.call(s,a)
return a},
$S:54}
A.eT.prototype={
$1(a){this.a.call(this.b,a)
return a},
$S:17}
A.dT.prototype={
$0(){return this.a.a},
$S:4}
A.dU.prototype={
$0(){var s,r=this.a,q=t.m,p=q.a(self),o=q.a(p.Object),n=q.a(o.create.apply(o,[null]))
n.set=A.aB(r.gL())
n.get=A.t(r.gJ())
o=q.a(p.Object)
s=q.a(o.create.apply(o,[null]))
s.get=A.l(new A.dT(r))
p=q.a(p.Object)
p.defineProperty.apply(p,[n,"object",s])
return n},
$S:2}
A.fK.prototype={
$1(a){var s,r,q,p,o=t.m
o.a(a)
s=this.a
if(s.a)return
r=o.a(o.a(a.detail).data)
if(A.fW(A.f(r.status))===B.p){q=A.aX(A.J(r))
o.a(self.console).error(q)
return}s.a=!0
s=self
o.a(s.window).addEventListener("WALLET_ACTIVATION",A.A(this))
p=A.bz(r)
if($.cz.b!==$.cz)A.a7(new A.b_("Field '"+$.cz.a+"' has already been initialized."))
$.cz.b="WALLET_"+p
o.a(s.window).addEventListener("ETH_"+p,A.A(new A.cl().gc3()))},
$S:10}
A.at.prototype={
ad(){return"JSWalletMessageType."+this.b}}
A.dE.prototype={
$1(a){return t.cP.a(a).b===this.a},
$S:29}
A.dF.prototype={
$0(){return A.a7(B.n)},
$S:7}
A.eQ.prototype={
$2(a,b){if(b instanceof A.x)this.a.t(0,a,A.i7(this.b,b))},
$S:16}
A.R.prototype={
ad(){return"JSEventType."+this.b}}
A.dr.prototype={
$1(a){return t.A.a(a).b===this.a},
$S:23}
A.ds.prototype={
$0(){return A.a7(B.n)},
$S:7}
A.dq.prototype={
$1(a){return t.A.a(a).b===this.a},
$S:23}
A.au.prototype={
ad(){return"JSWalletResponseType."+this.b}}
A.dG.prototype={
$1(a){return t.c9.a(a).b===this.a},
$S:32}
A.dH.prototype={
$0(){return A.a7(B.n)},
$S:7}
A.a_.prototype={
ad(){return"JSClientType."+this.b}}
A.dn.prototype={
$1(a){return t.D.a(a).b===this.a},
$S:33}
A.dp.prototype={
$0(){return A.a7(B.n)},
$S:7}
A.dm.prototype={
cC(a){var s,r,q,p,o,n=this
try{r=t.m
if(A.ju(A.f(r.a(a.data).type))===B.F){q=A.f(a.requestId)
r=r.a(a.data)
q=$.dP.j(0,q)
if(q!=null)q.b.aC(r)
return}s=r.a(a.data)
switch(A.jr(A.f(a.client))){case B.r:p=n.a
if(p===$){r=t.G
r=A.u([B.d,A.d([],r),B.e,A.d([],r),B.f,A.d([],r),B.l,A.d([],r),B.h,A.d([],r),B.i,A.d([],r)],t.A,t.u)
n.a!==$&&A.c3("ethereumPageController")
p=n.a=new A.cf(n.gai(),r)}p.T(s)
break
case B.w:p=n.b
if(p===$){r=t.G
r=A.u([B.d,A.d([],r),B.e,A.d([],r),B.f,A.d([],r),B.l,A.d([],r),B.h,A.d([],r),B.i,A.d([],r)],t.A,t.u)
n.b!==$&&A.c3("tronPageController")
p=n.b=new A.cO(n.gai(),r)}p.T(s)
break
case B.t:p=n.c
if(p===$){r=t.G
r=A.u([B.d,A.d([],r),B.e,A.d([],r),B.f,A.d([],r),B.l,A.d([],r),B.h,A.d([],r),B.i,A.d([],r)],t.A,t.u)
n.c!==$&&A.c3("solanaPageController")
p=n.c=new A.cF(n.gai(),r)}p.T(s)
break
case B.v:p=n.d
if(p===$){r=t.G
r=A.u([B.d,A.d([],r),B.e,A.d([],r),B.f,A.d([],r),B.l,A.d([],r),B.h,A.d([],r),B.i,A.d([],r)],t.A,t.u)
n.d!==$&&A.c3("tonPageController")
p=n.d=new A.cM(n.gai(),r)}p.T(s)
break
case B.u:p=n.e
if(p===$){r=t.G
r=A.u([B.d,A.d([],r),B.e,A.d([],r),B.f,A.d([],r),B.l,A.d([],r),B.h,A.d([],r),B.i,A.d([],r)],t.A,t.u)
n.e!==$&&A.c3("stellarPageController")
p=n.e=new A.cI(n.gai(),r)}p.T(s)
break
default:break}}catch(o){throw o}}}
A.cl.prototype={
cK(a){var s=$.cz.D(),r=self,q=t.m
s=q.a(new r.CustomEvent(s,{bubbles:!0,cancelable:!1,detail:a,data:null}))
q.a(r.window).dispatchEvent(s)},
c4(a){var s=t.m
this.cC(s.a(s.a(a).detail))}}
A.cy.prototype={
au(a){var s,r,q,p=t.m
p.a(a)
s=A.f(a.method)
r=t.r.a(a.params)
q=A.T(a.id)
return A.a2(this.a1(A.aw(q==null?B.b.i(this.b++):q,s,r)),p)},
ae(a){return this.bZ(a)},
bZ(a){var s=0,r=A.bZ(t.m),q,p=2,o,n=[],m=this,l,k,j,i
var $async$ae=A.c_(function(b,c){if(b===1){o=c
s=p}while(true)switch(s){case 0:i=new A.cA(A.jX(),new A.aO(new A.C($.v,t.aX),t.x))
p=3
k=i.a
j=m.ga0()
l={id:k,client:j.b,data:a}
m.a.$1(l)
k=i.a
if($.dP.j(0,k)==null)$.dP.t(0,k,i)
s=6
return A.hh(i.b.a,$async$ae)
case 6:k=c
q=k
n=[1]
s=4
break
n.push(5)
s=4
break
case 3:n=[2]
case 4:p=2
$.dP.G(0,i.a)
s=n.pop()
break
case 5:case 1:return A.bV(q,r)
case 2:return A.bU(o,r)}})
return A.bW($async$ae,r)},
ac(a){var s=A.ab(A.f(a.event))
if(!(s===B.d||s===B.e||s===B.f))return
s=this.ga0()
this.a.$1({id:"",client:s.b,data:a})},
M(a,b){return this.c2(a,b,b)},
c2(a,b,c){var s=0,r=A.bZ(c),q,p=this,o
var $async$M=A.c_(function(d,e){if(d===1)return A.bU(e,r)
while(true)$async$outer:switch(s){case 0:s=3
return A.hh(p.ae(a),$async$M)
case 3:o=e
switch(A.fW(A.f(o.status))){case B.y:q=b.a(o.data)
s=1
break $async$outer
case B.p:throw A.b(A.aX(A.J(o)))}case 1:return A.bV(q,r)}})
return A.bW($async$M,r)},
a1(a){var s=0,r=A.bZ(t.m),q,p=this,o
var $async$a1=A.c_(function(b,c){if(b===1)return A.bU(c,r)
while(true)$async$outer:switch(s){case 0:s=3
return A.hh(p.ae(a),$async$a1)
case 3:o=c
switch(A.fW(A.f(o.status))){case B.y:q={id:A.f(a.id),result:o.data}
s=1
break $async$outer
case B.p:q={id:A.f(a.id),error:A.aX(A.J(o))}
s=1
break $async$outer}case 1:return A.bV(q,r)}})
return A.bW($async$a1,r)}}
A.cf.prototype={
X(){var s,r,q,p,o,n,m,l=this
if(l.e==null){s=A.A(l.gaS())
r=A.t(l.gP())
q=A.t(l.gN())
A.l(l.gaK())
p=A.l(l.gaM())
o=A.l(l.gV())
n={}
n.sendWalletRequest=A.A(l.gar())
n.cancelListener=q
n.request=s
n.on=r
n.removeListener=q
n.providerInfo=$.fO()
n.enable=p
n.cancelAllListener=o
l.sbX(new A.O(n,t.a))}s=self
m=A.aD(s.Proxy,[l.e.a,new A.df(l).$0()],t.m)
s.ethereum=m
A.jk(m)},
T(a){var s,r,q,p=this,o="net_version",n=a.data
switch(A.ab(A.f(a.event))){case B.f:s=A.ha(A.f(A.J(a).j(0,o)),null)
r="0x"+s.a6(0,16)
n=new A.cD(r,s).gb4()
q=p.e
if(q!=null)q.a.chainId=r
r=p.e
if(r!=null)r.a.networkVersion=s.i(0)
break
case B.e:s=A.ha(A.f(A.J(a).j(0,o)),null)
r="0x"+s.a6(0,16)
n=A.N(r)
q=p.e
if(q!=null)q.a.chainId=r
r=p.e
if(r!=null)r.a.networkVersion=s.i(0)
break
case B.h:s=p.e
if(s!=null)s.a.chainId=null
s=p.e
if(s!=null)s.a.networkVersion=null
s=p.e
if(s!=null)s.a.selectedAddress=null
break
case B.d:s=A.J(a)
r=t.N
q=J.Z(t.j.a(s.j(0,"accounts")),r)
s=A.T(s.j(0,"defaultAddress"))
n=A.N(A.a5(q,r))
r=p.e
if(r!=null){r=r.a
if(s==null)s=null
r.selectedAddress=s}break
case B.k:s=A.bz(a)
r=self
r.ethereum=null
t.m.a(r.console).error(s)
break
case B.j:p.X()
break}p.C(A.ab(A.f(a.event)),n)},
C(a,b){var s,r,q
if(b==null||!this.c.E(a))return
s=this.c.j(0,a)
s.toString
s=A.B(s,!0,t.g)
for(r=s.length,q=0;q<r;++q)s[q].call(null,b)},
aL(){},
R(a,b){var s,r
A.f(a)
t.g.a(b)
s=A.ae(a)
if(s==null)return
r=this.c.j(0,s)
if(r!=null)B.a.k(r,b)
this.ac(A.cx(s))},
W(){var s,r,q,p,o
for(s=this.c,r=A.H(s).h("W<1>"),r=A.B(new A.W(s,r),!0,r.h("h.E")),q=r.length,p=0;p<q;++p){o=s.j(0,r[p])
o.toString
B.a.aB(o)}},
O(a,b){var s
A.f(a)
t.g.a(b)
s=this.c.j(0,A.ae(a))
if(s!=null)B.a.G(s,b)},
aN(){return this.aq({method:"eth_requestAccounts"})},
aq(a){var s,r,q
t.m.a(a)
s=A.f(a.method)
r=t.r.a(a.params)
q=t.X
return A.a2(this.M(A.aw(B.b.i(this.d++),s,r),q),q)},
ga0(){return B.r},
sbX(a){this.e=t.R.a(a)}}
A.de.prototype={
$0(){return this.a.a},
$S:4}
A.df.prototype={
$0(){var s,r,q,p,o,n=this.a.e
n.toString
s=t.m
r=s.a(self)
q=s.a(r.Object)
p=s.a(q.create.apply(q,[null]))
p.set=A.aB(n.gL())
p.get=A.t(n.gJ())
q=s.a(r.Object)
o=s.a(q.create.apply(q,[null]))
o.get=A.l(new A.de(n))
r=s.a(r.Object)
r.defineProperty.apply(r,[p,"object",o])
return p},
$S:2}
A.cF.prototype={
bT(){var s,r,q,p,o=this,n={},m=A.l(o.gbQ()),l=A.t(o.gP()),k=A.t(o.gca()),j=A.A(o.gcg()),i={},h=A.A(o.gcc()),g={}
g.connect=m
g.version="1.0.0"
i["standard:connect"]=g
g={}
g.on=l
g.version="1.0.0"
i["standard:events"]=g
s=$.iT()
g={}
g.signTransaction=j
g.version="1.0.0"
g.supportedTransactionVersions=s
i["solana:signTransaction"]=g
g={}
g.signAndSendTransaction=k
g.version="1.0.0"
g.supportedTransactionVersions=s
i["solana:signAndSendTransaction"]=g
g={}
g.signMessage=h
g.version="1.0.0"
i["solana:signMessage"]=g
n.signTransaction=j
n.signAllTransactions=A.A(o.gc8())
n.signAndSendTransaction=k
s=o.gN()
n.removeListener=A.t(s)
n.signMessage=h
n.connect=m
n.isConnected=!1
n.on=l
n.cancelListener=A.t(s)
n.sendWalletRequest=A.A(o.gbN())
n["sendTransaction "]=k
n.features=A.jQ(i,t.K)
n.name="MRT"
n.version="1.0.0"
n.icon=u.f
s=A.d([],t.O)
r=t.c
q=self
n.accounts=r.a(q.Object.freeze(s))
s=$.iU()
n.chains=r.a(q.Object.freeze(s))
s=t.m
p=s.a(new q.CustomEvent("wallet-standard:register-wallet",{bubbles:!1,cancelable:!1,detail:A.A(new A.e3(n))}))
s.a(q.window).addEventListener("wallet-standard:app-ready",A.A(new A.e4(p)))
s.a(q.window).dispatchEvent(p)
return new A.O(n,t.a)},
X(){var s,r=this
if(r.d==null)r.scl(r.bT())
s=self
s.solana=A.aD(s.Proxy,[r.d.a,new A.e6(r).$0()],t.m)},
cd(a){var s=A.h_(A.d(["account","message"],t.s),a,t.m),r=t.K
return A.a2(this.M(A.aw(null,"solana_signMessage",[a]),t.X).a5(new A.e8(s),r),r)},
ci(a){return A.a2(this.aa("solana_signTransaction",A.d([this.az(t.K.a(a))],t.O)),t.X)},
c9(a){var s,r,q,p,o,n,m
t.c.a(a)
s=t.co.b(a)?a:new A.K(a,A.F(a).h("K<1,c>"))
r=A.d([],t.O)
for(q=J.ba(s),p=t.s,o=t.m;q.n();){n=q.gp()
m=A.h_(A.d(["account","transaction"],p),n,o)
if(m==null)m=null
else m.txType="walletAdapter"
if(m==null)m=A.hZ(n)
if(m==null)A.a7(A.jW(A.i8().cW()))
B.a.k(r,m)}return A.a2(this.aa("solana_signAllTransactions",r),t.X)},
az(a){var s,r=A.h_(A.d(["account","transaction"],t.s),a,t.m)
if(r==null)r=null
else r.txType="walletAdapter"
if(r==null)r=A.hZ(a)
if(r==null){s=A.i8()
throw A.b(A.hK(new A.cS(s.a,s.b,s.c,s.d),null))}return r},
aa(a,b){var s=0,r=A.bZ(t.X),q,p=this,o,n
var $async$aa=A.c_(function(c,d){if(c===1)return A.bU(d,r)
while(true)switch(s){case 0:n=t.cx.b(b)?b:new A.K(b,A.F(b).h("K<1,i>"))
n=J.c6(n,new A.dZ(),t.m)
o=t.X
q=A.a2(p.M(A.aw(null,a,A.B(n,!0,n.$ti.h("w.E"))),o).a5(new A.e_(p,a,b),o),o)
s=1
break
case 1:return A.bV(q,r)}})
return A.bW($async$aa,r)},
bo(a,b){var s,r
t.K.a(a)
s=t.B
s.a(b)
r=this.az(a)
if(s.a(r.options)==null)r.options=b
return A.a2(this.aa("solana_sendTransaction",A.d([r],t.O)),t.X)},
cb(a){return this.bo(a,null)},
bO(a){var s,r,q,p=this,o=t.m
o.a(a)
switch(A.f(a.method)){case"solana_requestAccounts":return p.au(a)
case"solana_signMessage":s=A.f(a.method)
r=t.r.a(a.params)
q=A.T(a.id)
return A.a2(p.a1(A.aw(q==null?B.b.i(p.b++):q,s,r)).a5(new A.e0(),o),o)
default:return A.a2(p.aZ(a),t.X)}},
aZ(a){var s=0,r=A.bZ(t.X),q,p=this,o,n,m,l,k,j,i,h
var $async$aZ=A.c_(function(b,c){if(b===1)return A.bU(c,r)
while(true)$async$outer:switch(s){case 0:i=A.jY(A.f(a.method))
h=A.T(a.id)
if(h==null)h=B.b.i(p.b++)
if(i==null){q={id:h,error:A.aX(B.I.H())}
s=1
break}o=t.r
n=o.a(a.params)
if(n==null||A.X(n.length)===0){q={id:h,error:A.aX(new A.aN(u.b,-32602,"WEB3-5100","Transaction serialization failed").H())}
s=1
break}m=A.d([],t.O)
switch(i){case B.K:o=o.a(a.params)
n=o==null?null:A.fV(o,0,t.K,t.c)
if(n==null)l=null
else{o=B.a.a4(n,new A.e9(p),t.m)
l=A.B(o,!0,o.$ti.h("w.E"))}if(l==null){q={id:h,error:A.aX(new A.aN("Invalid method parameters: Invalid batch transaction request. The first parameter must be a list of transactions when sending a batch request.",-32602,"WEB3-5100","Invalid batch transaction request. The first parameter must be a list of transactions when sending a batch request.").H())}
s=1
break $async$outer}B.a.b_(m,new A.K(l,A.F(l).h("K<1,i>")))
break
case B.A:case B.J:o=t.K
k=p.az(A.fV(n,0,o,t.X))
if(i===B.A){j=t.B
k.options=A.fV(n,1,o,j)
if(j.a(k.options)==null)k.options={skipPreflight:!1}}B.a.k(m,k)
break
default:q={id:h,error:A.aX(B.I.H())}
s=1
break $async$outer}o=t.m
q=A.a2(p.a1(A.aw(h,A.f(a.method),m)).a5(new A.ea(p,a,m),o),o)
s=1
break
case 1:return A.bV(q,r)}})
return A.bW($async$aZ,r)},
bj(a,b,c){var s,r,q,p,o,n,m,l,k,j,i,h="solana_signTransaction"
switch(a){case"solana_signTransaction":case"solana_signAllTransactions":s=A.d([],t.I)
r=J.c6(t.j.a(A.am(b)),new A.e7(),t.cV)
q=A.B(r,!0,r.$ti.h("w.E"))
for(r=t.m,p=t.K,o=0;o<A.X(c.length);++o){if(!(o<q.length))return A.e(q,o)
n=q[o]
if(n==null)continue
m=r.a(c[o])
l=n.d
k=n.b
j=self
i=p.a(j.Uint8Array.from(A.N(k)))
j=new j.BN(p.a(i.slice()))
B.a.k(s,A.js(m,n.a,n.c,new A.bk(l,i,j)))}if(a===h&&A.hJ(A.T(r.a(c[0]).txType))===B.x){if(0>=s.length)return A.e(s,0)
return s[0]}return s
case"solana_requestAccounts":return b
case"solana_sendTransaction":return b
default:return null}},
bR(){var s=t.c
return A.a2(this.M(A.aw(null,"solana_requestAccounts",null),s).a5(new A.e2(),s),s)},
T(a){var s,r,q,p,o=this,n=null,m=a.data
switch(A.ab(A.f(a.event))){case B.f:s=A.hW(A.J(a))
r=s.c
m=r.gu()
q=o.d
if(q!=null)A.hY(q.a,s)
o.C(B.i,A.eh(s.a,n).aG())
o.C(B.i,A.eh(n,A.d([r.b],t.s)).aG())
break
case B.e:s=A.hX(A.J(a))
o.C(B.i,A.eh(n,A.d([s.b],t.s)).aG())
m=s.gu()
break
case B.d:s=A.hW(A.J(a))
r=o.d
if(r!=null)A.hY(r.a,s)
r=s.a
o.C(B.i,A.eh(r,n).aG())
q=A.F(r)
p=q.h("y<1,j>")
m=A.B(new A.y(r,q.h("j(1)").a(new A.eb()),p),!0,p.h("w.E"))
break
case B.h:r=o.d
if(r!=null)r.a.publicKey=null
r=o.d
if(r!=null)r.a.isConnected=!1
break
case B.k:r=A.bz(a)
q=self
q.solana=null
t.m.a(q.console).error(r)
return
case B.j:o.X()
return
default:return}o.C(A.ab(A.f(a.event)),m)},
C(a,b){var s,r,q=this.c
if(!q.E(a))return
q=q.j(0,a)
q.toString
q=A.B(q,!0,t.g)
for(s=q.length,r=0;r<s;++r)q[r].call(null,b)},
R(a,b){var s,r
A.f(a)
t.g.a(b)
s=A.ae(a)
r=this.c
if(!r.E(s))return
r=r.j(0,s)
if(r!=null)B.a.k(r,b)
s.toString
this.ac(A.cx(s))},
O(a,b){var s
A.f(a)
t.g.a(b)
s=this.c.j(0,A.ae(a))
if(s!=null)B.a.G(s,b)},
ga0(){return B.t},
scl(a){this.d=t.R.a(a)}}
A.e3.prototype={
$1(a){var s=t.K
s.a(s.a(a).register(this.a))},
$S:21}
A.e4.prototype={
$1(a){t.K.a(a)
t.m.a(self.window).dispatchEvent(this.a)},
$S:21}
A.e5.prototype={
$0(){return this.a.a},
$S:4}
A.e6.prototype={
$0(){var s,r,q,p,o,n=this.a.d
n.toString
s=t.m
r=s.a(self)
q=s.a(r.Object)
p=s.a(q.create.apply(q,[null]))
p.set=A.aB(n.gL())
p.get=A.t(n.gJ())
q=s.a(r.Object)
o=s.a(q.create.apply(q,[null]))
o.get=A.l(new A.e5(n))
r=s.a(r.Object)
r.defineProperty.apply(r,[p,"object",o])
return p},
$S:2}
A.e8.prototype={
$1(a){var s=A.hI(t.f.a(A.am(a)).a2(0,t.N,t.z))
if(this.a!=null)return A.d([s],t.O)
return s},
$S:42}
A.dZ.prototype={
$1(a){return t.m.a(a)},
$S:5}
A.e_.prototype={
$1(a){return this.a.bj(this.b,a,this.c)},
$S:9}
A.e0.prototype={
$1(a){var s
t.m.a(a)
if(a.error!=null)return a
s=A.hI(t.f.a(A.am(a.result)).a2(0,t.N,t.z))
return{id:A.f(a.id),result:s}},
$S:5}
A.e9.prototype={
$1(a){return this.a.az(a)},
$S:14}
A.ea.prototype={
$1(a){t.m.a(a)
if(a.error!=null)return a
return{id:A.f(a.id),result:this.a.bj(A.f(this.b.method),a.result,this.c)}},
$S:5}
A.e7.prototype={
$1(a){var s,r,q,p,o,n,m
if(a==null)return null
s=t.f.a(a).a2(0,t.N,t.z)
r=s.a
s=s.$ti.h("4?")
q=t.j
p=t.S
o=J.Z(q.a(s.a(r.j(0,"signature"))),p)
n=J.Z(q.a(s.a(r.j(0,"signerAddressBytes"))),p)
m=A.f(s.a(r.j(0,"signer")))
r=J.Z(q.a(s.a(r.j(0,"serializedTx"))),p)
A.fT(o)
o=A.a5(o,p)
A.fT(n)
n=A.a5(n,p)
A.fT(r)
return new A.aV(o,n,A.a5(r,p),m)},
$S:43}
A.e2.prototype={
$1(a){var s
t.c.a(a)
s=B.a.a4(a,new A.e1(),t.m)
return A.B(s,!0,s.$ti.h("w.E"))},
$S:44}
A.e1.prototype={
$1(a){return A.h2(t.f.a(A.am(a)).a2(0,t.N,t.z)).gu()},
$S:14}
A.eb.prototype={
$1(a){return t.Q.a(a).a},
$S:45}
A.cI.prototype={
X(){var s,r,q=this
if(q.d==null){s={}
s.enable=A.l(q.gaV())
r=q.gP()
s.on=A.t(r)
s.on=A.t(r)
r=q.gN()
s.removeListener=A.t(r)
s.cancelListener=A.t(r)
s.sendWalletRequest=A.A(q.gar())
s.cancelAllListener=A.l(q.gV())
q.scm(new A.O(s,t.a))}r=self
r.stellar=A.aD(r.Proxy,[q.d.a,new A.en(q).$0()],t.m)},
aW(){return this.au({method:"stellar_requestAccounts"})},
T(a){var s,r,q,p,o=this,n="passphrase",m=a.data
switch(A.ab(A.f(a.event))){case B.f:m=A.f(A.J(a).j(0,n))
break
case B.e:m=new A.bw(A.f(A.J(a).j(0,n))).gu()
break
case B.d:s=A.J(a)
r=t.N
q=J.Z(t.j.a(s.j(0,"accounts")),r)
p=A.T(s.j(0,"defaultAddress"))
s=A.f(t.b.a(s.j(0,"connectInfo")).j(0,n))
m=new A.ek(A.a5(q,r),p,new A.bw(s)).gcr()
s=o.d
if(s!=null){s=s.a
r=p==null?null:p
s.selectedAddress=r}break
case B.h:s=o.d
if(s!=null)s.a.selectedAddress=null
break
case B.k:s=A.bz(a)
r=self
r.ton=null
t.m.a(r.console).error(s)
return
case B.j:o.X()
return
default:return}o.C(A.ab(A.f(a.event)),m)},
C(a,b){var s,r,q=this.c
if(!q.E(a))return
q=q.j(0,a)
q.toString
q=A.B(q,!0,t.g)
for(s=q.length,r=0;r<s;++r)q[r].call(null,b)},
R(a,b){var s,r
A.f(a)
t.g.a(b)
s=A.ae(a)
if(s==null||!this.c.E(s))return
r=this.c.j(0,s)
if(r!=null)B.a.k(r,b)
this.ac(A.cx(s))},
O(a,b){var s
A.f(a)
t.g.a(b)
s=this.c.j(0,A.ae(a))
if(s!=null)B.a.G(s,b)},
W(){var s,r,q,p,o
for(s=this.c,r=A.H(s).h("W<1>"),r=A.B(new A.W(s,r),!0,r.h("h.E")),q=r.length,p=0;p<q;++p){o=s.j(0,r[p])
o.toString
B.a.aB(o)}},
ga0(){return B.u},
scm(a){this.d=t.R.a(a)}}
A.em.prototype={
$0(){return this.a.a},
$S:4}
A.en.prototype={
$0(){var s,r,q,p,o,n=this.a.d
n.toString
s=t.m
r=s.a(self)
q=s.a(r.Object)
p=s.a(q.create.apply(q,[null]))
p.set=A.aB(n.gL())
p.get=A.t(n.gJ())
q=s.a(r.Object)
o=s.a(q.create.apply(q,[null]))
o.get=A.l(new A.em(n))
r=s.a(r.Object)
r.defineProperty.apply(r,[p,"object",o])
return p},
$S:2}
A.cM.prototype={
X(){var s,r,q=this
if(q.d==null){s={}
s.enable=A.l(q.gaV())
r=q.gP()
s.on=A.t(r)
s.on=A.t(r)
r=q.gN()
s.removeListener=A.t(r)
s.cancelListener=A.t(r)
s.sendWalletRequest=A.A(q.gar())
s.cancelAllListener=A.l(q.gV())
q.sco(new A.O(s,t.a))}r=self
r.ton=A.aD(r.Proxy,[q.d.a,new A.et(q).$0()],t.m)},
aW(){return this.au({method:"ton_requestAccounts"})},
T(a){var s,r,q,p=this,o="workChain",n=a.data
switch(A.ab(A.f(a.event))){case B.f:n=A.X(A.J(a).j(0,o))
break
case B.e:n=new A.cL(A.X(A.J(a).j(0,o))).gu()
break
case B.d:s=A.J(a)
r=t.N
q=J.Z(t.j.a(s.j(0,"accounts")),r)
s=A.T(s.j(0,"defaultAddress"))
n=A.N(A.a5(q,r))
r=p.d
if(r!=null){r=r.a
if(s==null)s=null
r.selectedAddress=s}break
case B.h:s=p.d
if(s!=null)s.a.selectedAddress=null
break
case B.k:s=A.bz(a)
r=self
r.ton=null
t.m.a(r.console).error(s)
return
case B.j:p.X()
return
default:return}p.C(A.ab(A.f(a.event)),n)},
C(a,b){var s,r,q=this.c
if(!q.E(a))return
q=q.j(0,a)
q.toString
q=A.B(q,!0,t.g)
for(s=q.length,r=0;r<s;++r)q[r].call(null,b)},
R(a,b){var s,r
A.f(a)
t.g.a(b)
s=A.ae(a)
if(s==null||!this.c.E(s))return
r=this.c.j(0,s)
if(r!=null)B.a.k(r,b)
this.ac(A.cx(s))},
O(a,b){var s
A.f(a)
t.g.a(b)
s=this.c.j(0,A.ae(a))
if(s!=null)B.a.G(s,b)},
W(){var s,r,q,p,o
for(s=this.c,r=A.H(s).h("W<1>"),r=A.B(new A.W(s,r),!0,r.h("h.E")),q=r.length,p=0;p<q;++p){o=s.j(0,r[p])
o.toString
B.a.aB(o)}},
ga0(){return B.v},
sco(a){this.d=t.R.a(a)}}
A.es.prototype={
$0(){return this.a.a},
$S:4}
A.et.prototype={
$0(){var s,r,q,p,o,n=this.a.d
n.toString
s=t.m
r=s.a(self)
q=s.a(r.Object)
p=s.a(q.create.apply(q,[null]))
p.set=A.aB(n.gL())
p.get=A.t(n.gJ())
q=s.a(r.Object)
o=s.a(q.create.apply(q,[null]))
o.get=A.l(new A.es(n))
r=s.a(r.Object)
r.defineProperty.apply(r,[p,"object",o])
return p},
$S:2}
A.cO.prototype={
c_(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b=c.d
if(b!=null&&c.e!=null){s=self
s.tron=A.aD(s.Proxy,[b.a,new A.eA(c).$0()],t.m)}if(c.d!=null){b=c.e
if(b!=null)b.a.fullNode=new self.TronWeb.providers.HttpProvider(a.b)
b=c.e
if(b!=null)b.a.solidityNode=new self.TronWeb.providers.HttpProvider(a.b)
return}r=a.cX()
b=t.m
s=b.a(r.trx)
q=t.a
b.a(r.trx).sign=A.t(c.gcj())
b.a(r.trx).signMessageV2=A.t(c.gce())
b.a(r.trx).multiSign=A.t(c.gc0())
p=c.gbU()
r.setPrivateKey=A.A(p)
r.setAddress=A.A(p)
r.setFullNode=A.A(p)
r.setSolidityNode=A.A(p)
r.setHeader=A.A(p)
r.setFullNodeHeader=A.A(p)
r.setDefaultBlock=A.A(p)
r.defaultPrivateKey=""
p=self
r.trx=A.aD(p.Proxy,[b.a(r.trx),new A.eB(new A.O(s,q)).$0()],b)
r.defaultAddress=new A.af("","").gu()
o=new A.O(r,t.ce)
n=A.aD(p.Proxy,[r,new A.eC(o).$0()],b)
s=A.A(c.gaS())
m=A.t(c.gP())
l=A.t(c.gN())
A.l(c.gaK())
k=A.l(c.gaM())
j=A.l(c.gV())
i=A.A(c.gar())
h={}
h.dappIcon=""
h.dappName=""
h.openTronLinkAppOnMobile=!0
h.openUrlWhenWalletNotFound=!0
g={}
g.sendWalletRequest=i
g.cancelAllListener=j
g.cancelAllListener=l
g.tronlinkParams=h
g.request=s
g.on=m
g.removeListener=l
g.tronWeb=n
g.providerInfo=$.fO()
g.ready=!0
g.enable=k
f=b.a(p.Object.freeze(g))
e=new A.O(f,q)
d=A.aD(p.Proxy,[f,new A.eD(e).$0()],b)
p.tronLink=d
p.tronWeb=n
c.scp(e)
c.scq(o)
p.tron=d},
bV(a){throw A.b({message:"this feature disabled by wallet provider."})},
bp(a,b){t.K.a(a)
if(A.T(b)!=null)throw A.b({message:u.h})
return this.aw("tron_signMessageV2",A.am(a))},
cf(a){return this.bp(a,null)},
bq(a,b){var s
t.K.a(a)
A.T(b)
s=b==null?null:b.length!==0
if(s===!0)throw A.b({message:u.h})
return this.aw("tron_signTransaction",A.am(a))},
ck(a){return this.bq(a,null)},
bi(a,b){t.K.a(a)
if(A.T(b)!=null)throw A.b({message:u.h})
return this.aw("tron_signTransaction",A.am(a))},
c1(a){return this.bi(a,null)},
T(a){var s,r,q,p,o,n,m=this,l=null,k="defaultAddress",j=a.data
switch(A.ab(A.f(a.event))){case B.f:s=A.i4(A.J(a))
r=m.d
if(r!=null)r.a.chainId=s.a
j=s.gb4()
r=t.N
t.m.a(self.window).postMessage(A.N(A.u(["message",A.u(["action","connect"],r,r)],r,t.aN)))
break
case B.e:s=A.i4(A.J(a))
r=m.d
if(r!=null)r.a.chainId=s.a
r=m.e
if(r!=null)r.a.fullNode=new self.TronWeb.providers.HttpProvider(s.d)
r=m.e
if(r!=null)r.a.solidityNode=new self.TronWeb.providers.HttpProvider(s.d)
r=s.a
j=A.N(r)
q=t.m.a(self.window)
p=s.d
o=t.N
p=A.u(["chainId",r,"fullNode",p,"solidityNode",s.c,"eventServer",p],o,o)
q.postMessage(A.N(A.u(["message",A.u(["action","setNode","data",p],o,t.X)],o,t.aE)))
break
case B.h:r=m.d
if(r!=null)r.a.chainId=null
r=m.e
if(r!=null)r.a.defaultAddress=new A.af("","").gu()
break
case B.d:r=A.J(a)
q=t.N
p=J.Z(t.j.a(r.j(0,"accounts")),q)
if(r.j(0,k)==null)r=l
else{r=t.b.a(r.j(0,k))
r=new A.af(A.f(r.j(0,"base58")),A.f(r.j(0,"hex")))}p=A.a5(p,q)
o=m.e
if(o!=null){o=o.a
n=r==null?l:r.gu()
if(n==null)n=new A.af("","").gu()
o.defaultAddress=n}o=m.d
if(o!=null){o=o.a
n=r==null?l:r.a
o.selectedAddress=n}j=A.N(p)
r=r==null?l:r.a
t.m.a(self.window).postMessage(A.N(A.u(["message",A.u(["action","accountsChanged","data",A.u(["address",r],q,t.aD)],q,t.K)],q,t.c1)))
break
case B.k:r=A.bz(a)
q=self
q.tron=null
t.m.a(q.console).error(r)
break
case B.j:r=A.J(a)
A.f(r.j(0,"solidityNode"))
q=A.f(r.j(0,"fullNode"))
A.f(r.j(0,"chainId"))
p=A.T(r.j(0,"hex"))
m.c_(new A.eE(q,A.T(r.j(0,"base58")),p,A.T(r.j(0,"eventServer"))))
break}m.C(A.ab(A.f(a.event)),j)},
C(a,b){var s,r,q
if(a===B.h)return
if(b==null||!this.c.E(a))return
s=this.c.j(0,a)
s.toString
s=A.B(s,!0,t.g)
for(r=s.length,q=0;q<r;++q)s[q].call(null,b)},
aL(){},
R(a,b){var s,r
A.f(a)
t.g.a(b)
s=A.ae(a)
if(s==null)return
r=this.c.j(0,s)
if(r!=null)B.a.k(r,b)
this.ac(A.cx(s))},
O(a,b){var s
A.f(a)
t.g.a(b)
s=this.c.j(0,A.ae(a))
if(s!=null)B.a.G(s,b)},
W(){var s,r,q,p,o
for(s=this.c,r=A.H(s).h("W<1>"),r=A.B(new A.W(s,r),!0,r.h("h.E")),q=r.length,p=0;p<q;++p){o=s.j(0,r[p])
o.toString
B.a.aB(o)}},
aN(){return this.c6("tron_requestAccounts")},
aw(a,b){var s=t.X
return A.a2(this.M(A.aw(null,a,[b==null?null:A.N(b)]),s),s)},
c6(a){return this.aw(a,null)},
aq(a){var s
t.m.a(a)
s=t.X
return A.a2(this.M(A.aw(null,A.f(a.method),t.r.a(a.params)),s),s)},
ga0(){return B.w},
scp(a){this.d=t.R.a(a)},
scq(a){this.e=t.cZ.a(a)}}
A.ez.prototype={
$0(){return this.a.a},
$S:4}
A.eA.prototype={
$0(){var s,r,q,p,o,n=this.a.d
n.toString
s=t.m
r=s.a(self)
q=s.a(r.Object)
p=s.a(q.create.apply(q,[null]))
p.set=A.aB(n.gL())
p.get=A.t(n.gJ())
q=s.a(r.Object)
o=s.a(q.create.apply(q,[null]))
o.get=A.l(new A.ez(n))
r=s.a(r.Object)
r.defineProperty.apply(r,[p,"object",o])
return p},
$S:2}
A.ey.prototype={
$0(){return this.a.a},
$S:4}
A.eB.prototype={
$0(){var s,r=this.a,q=t.m,p=q.a(self),o=q.a(p.Object),n=q.a(o.create.apply(o,[null]))
n.set=A.aB(r.gL())
n.get=A.t(r.gJ())
o=q.a(p.Object)
s=q.a(o.create.apply(o,[null]))
s.get=A.l(new A.ey(r))
p=q.a(p.Object)
p.defineProperty.apply(p,[n,"object",s])
return n},
$S:2}
A.ex.prototype={
$0(){return this.a.a},
$S:4}
A.eC.prototype={
$0(){var s,r=this.a,q=t.m,p=q.a(self),o=q.a(p.Object),n=q.a(o.create.apply(o,[null]))
n.set=A.aB(r.gL())
n.get=A.t(r.gJ())
o=q.a(p.Object)
s=q.a(o.create.apply(o,[null]))
s.get=A.l(new A.ex(r))
p=q.a(p.Object)
p.defineProperty.apply(p,[n,"object",s])
return n},
$S:2}
A.ew.prototype={
$0(){return this.a.a},
$S:4}
A.eD.prototype={
$0(){var s,r=this.a,q=t.m,p=q.a(self),o=q.a(p.Object),n=q.a(o.create.apply(o,[null]))
n.set=A.aB(r.gL())
n.get=A.t(r.gJ())
o=q.a(p.Object)
s=q.a(o.create.apply(o,[null]))
s.get=A.l(new A.ew(r))
p=q.a(p.Object)
p.defineProperty.apply(p,[n,"object",s])
return n},
$S:2}
A.ef.prototype={
$1(a){return t.Q.a(a).gu()},
$S:22}
A.aV.prototype={}
A.as.prototype={
ad(){return"JSSolanalaTransactionType."+this.b}}
A.dv.prototype={
$1(a){return t.a6.a(a).b===this.a},
$S:49}
A.dw.prototype={
$0(){return A.a7(B.n)},
$S:7}
A.bk.prototype={
cw(a){var s
t.B.a(a)
s=a==null?null:a._bn
return A.ku(this.c.eq(s))},
cQ(){return this.a},
cV(){return this.a},
i(a){return this.a},
cS(){return t.K.a(this.b.slice())},
gu(){return new A.du(this).$0()}}
A.dt.prototype={
$0(){return this.a.c},
$S:2}
A.du.prototype={
$0(){var s,r=this.a,q=t.m,p=q.a(self),o=q.a(p.Object),n=q.a(o.create.apply(o,[null]))
n.equals=A.A(r.gcv())
n.toBase58=A.l(r.gcP())
n.toJSON=A.l(r.gcU())
n.toString=A.l(r.gB(r))
n.toBytes=A.l(r.gcR())
o=q.a(p.Object)
s=q.a(o.create.apply(o,[null]))
s.get=A.l(new A.dt(r))
p=q.a(p.Object)
p.defineProperty.apply(p,[n,"_bn",s])
return n},
$S:2}
A.a1.prototype={
H(){var s=this
return A.u(["base58",s.a,"bytes",s.b,"features",s.d,"chains",s.c],t.N,t.z)},
gu(){var s,r,q,p={}
p.address=this.a
s=this.c
r=A.F(s)
q=r.h("y<1,j>")
q=A.B(new A.y(s,r.h("j(1)").a(new A.ee()),q),!0,q.h("w.E"))
r=t.c
s=self
p.chains=r.a(s.Object.freeze(q))
q=$.iS()
p.features=r.a(s.Object.freeze(q))
p.publicKey=t.K.a(s.Uint8Array.from(A.N(this.b)))
return p}}
A.ee.prototype={
$1(a){return A.f(a)},
$S:8}
A.dW.prototype={
H(){var s,r,q=this.a,p=A.F(q),o=p.h("y<1,S<j,@>>")
o=A.B(new A.y(q,p.h("S<j,@>(1)").a(new A.dY()),o),!0,o.h("w.E"))
p=this.b
q=p==null?null:p.H()
p=this.c
s=t.N
r=t.z
return A.u(["accounts",o,"defaultAddress",q,"connectInfo",A.u(["genesisBlock",p.a,"name",p.b],s,r)],s,r)},
i(a){return"SolanaAccountsChanged"+this.H().i(0)}}
A.dX.prototype={
$1(a){return A.h2(t.f.a(a).a2(0,t.N,t.z))},
$S:51}
A.dY.prototype={
$1(a){return t.Q.a(a).H()},
$S:40}
A.cG.prototype={
gu(){return new A.ed(this).$0()},
i(a){return this.a}}
A.ec.prototype={
$0(){return this.a.a},
$S:1}
A.ed.prototype={
$0(){var s,r=this.a,q=t.m,p=q.a(self),o=q.a(p.Object),n=q.a(o.create.apply(o,[null]))
n.toString=A.l(r.gB(r))
o=q.a(p.Object)
s=q.a(o.create.apply(o,[null]))
s.get=A.l(new A.ec(r))
p=q.a(p.Object)
p.defineProperty.apply(p,[n,"genesisBlock",s])
return n},
$S:2}
A.eg.prototype={
aG(){var s,r,q={},p=this.a
if(p==null)p=null
else{s=A.F(p)
r=s.h("y<1,j>")
r=A.B(new A.y(p,s.h("j(1)").a(new A.ei()),r),!0,r.h("w.E"))
p=r}q.chains=p
p=this.b
if(p==null)p=null
else{s=A.F(p)
r=s.h("y<1,i>")
r=A.B(new A.y(p,s.h("i(1)").a(new A.ej()),r),!0,r.h("w.E"))
p=r}q.accounts=p
return q}}
A.ei.prototype={
$1(a){return A.f(a)},
$S:8}
A.ej.prototype={
$1(a){return t.Q.a(a).gu()},
$S:22}
A.ek.prototype={
gcr(){var s=this.a,r=A.F(s),q=r.h("y<1,j>")
return A.B(new A.y(s,r.h("j(1)").a(new A.el()),q),!0,q.h("w.E"))},
i(a){var s=t.N,r=t.z
return"StellarAccountsChanged"+A.u(["accounts",this.a,"defaultAddress",this.b,"connectInfo",A.u(["passphrase",this.c.a],s,r)],s,r).i(0)}}
A.el.prototype={
$1(a){return A.f(a)},
$S:8}
A.bw.prototype={
gu(){return new A.ep(this).$0()},
i(a){return this.a}}
A.eo.prototype={
$0(){return this.a.a},
$S:1}
A.ep.prototype={
$0(){var s,r=this.a,q=t.m,p=q.a(self),o=q.a(p.Object),n=q.a(o.create.apply(o,[null]))
n.toString=A.l(r.gB(r))
o=q.a(p.Object)
s=q.a(o.create.apply(o,[null]))
s.get=A.l(new A.eo(r))
p=q.a(p.Object)
p.defineProperty.apply(p,[n,"passphrase",s])
return n},
$S:2}
A.h3.prototype={
i(a){return"TonAccountsChanged"+A.u(["accounts",this.a,"defaultAddress",this.b],t.N,t.z).i(0)}}
A.cL.prototype={
gu(){return new A.er(this).$0()},
i(a){return"TonChainChanged"+A.u(["workChain",this.a],t.N,t.z).i(0)}}
A.eq.prototype={
$0(){return this.a.a},
$S:38}
A.er.prototype={
$0(){var s,r=this.a,q=t.m,p=q.a(self),o=q.a(p.Object),n=q.a(o.create.apply(o,[null]))
n.toString=A.l(r.gB(r))
o=q.a(p.Object)
s=q.a(o.create.apply(o,[null]))
s.get=A.l(new A.eq(r))
p=q.a(p.Object)
p.defineProperty.apply(p,[n,"workChain",s])
return n},
$S:2}
A.af.prototype={
i(a){return this.a},
U(a,b){if(b==null)return!1
if(!(b instanceof A.af))return!1
return this.b===b.b},
gu(){return new A.dz(this).$0()},
gq(a){return B.m.gq(this.b)^B.m.gq(this.a)}}
A.dx.prototype={
$0(){return this.a.a},
$S:1}
A.dy.prototype={
$0(){return this.a.b},
$S:1}
A.dz.prototype={
$0(){var s,r,q=this.a,p=t.m,o=p.a(self),n=p.a(o.Object),m=p.a(n.create.apply(n,[null]))
m.toString=A.l(q.gB(q))
n=p.a(o.Object)
s=p.a(n.create.apply(n,[null]))
s.get=A.l(new A.dx(q))
n=p.a(o.Object)
n.defineProperty.apply(n,[m,"base58",s])
n=p.a(o.Object)
r=p.a(n.create.apply(n,[null]))
r.get=A.l(new A.dy(q))
o=p.a(o.Object)
o.defineProperty.apply(o,[m,"hex",r])
return m},
$S:2}
A.eE.prototype={
cO(){var s,r=this.d
if(r==null||this.e==null)return null
r.toString
s=this.e
s.toString
return new A.af(r,s)},
cX(){var s,r,q,p
try{q=this.b
s=new self.TronWeb(q,q,this.f)
r=this.cO()
q=r==null?null:new A.eH(r).$0()
s.defaultAddress=q
return s}catch(p){throw p}}}
A.eF.prototype={
$0(){return this.a.a},
$S:1}
A.eG.prototype={
$0(){return this.a.b},
$S:1}
A.eH.prototype={
$0(){var s,r,q=this.a,p=t.m,o=p.a(self),n=p.a(o.Object),m=p.a(n.create.apply(n,[null]))
m.toString=A.l(J.ja(q))
n=p.a(o.Object)
s=p.a(n.create.apply(n,[null]))
s.get=A.l(new A.eF(q))
n=p.a(o.Object)
n.defineProperty.apply(n,[m,"base58",s])
n=p.a(o.Object)
r=p.a(n.create.apply(n,[null]))
r.get=A.l(new A.eG(q))
o=p.a(o.Object)
o.defineProperty.apply(o,[m,"hex",r])
return m},
$S:2}
A.h4.prototype={
i(a){var s=this.b
s=s==null?null:A.u(["base58",s.a,"hex",s.b],t.N,t.z)
return"TronAccountsChanged"+A.u(["accounts",this.a,"defaultAddress",s],t.N,t.z).i(0)}}
A.cN.prototype={
gb4(){return new A.ev(this).$0()},
i(a){var s=t.N
return"ProviderConnectInfo"+A.u(["chainId",this.a],s,s).i(0)}}
A.eu.prototype={
$0(){return this.a.a},
$S:1}
A.ev.prototype={
$0(){var s,r=this.a,q=t.m,p=q.a(self),o=q.a(p.Object),n=q.a(o.create.apply(o,[null]))
n.toString=A.l(r.gB(r))
o=q.a(p.Object)
s=q.a(o.create.apply(o,[null]))
s.get=A.l(new A.eu(r))
p=q.a(p.Object)
p.defineProperty.apply(p,[n,"chainId",s])
return n},
$S:2};(function aliases(){var s=J.av.prototype
s.bH=s.i})();(function installTearOffs(){var s=hunkHelpers._static_1,r=hunkHelpers._static_0,q=hunkHelpers.installInstanceTearOff,p=hunkHelpers._instance_2u,o=hunkHelpers._instance_0i,n=hunkHelpers._instance_1u,m=hunkHelpers._instance_0u
s(A,"la","k0",13)
s(A,"lb","k1",13)
s(A,"lc","k2",13)
r(A,"iI","l3",0)
var l
q(l=A.O.prototype,"gL",0,4,null,["$4"],["bD"],41,0,0)
p(l,"gJ","bC",34)
o(A.cD.prototype,"gB","i",1)
n(l=A.cl.prototype,"gai","cK",10)
n(l,"gc3","c4",10)
n(A.cy.prototype,"gar","au",5)
m(l=A.cf.prototype,"gaK","aL",0)
p(l,"gP","R",3)
m(l,"gV","W",0)
p(l,"gN","O",3)
m(l,"gaM","aN",6)
n(l,"gaS","aq",5)
n(l=A.cF.prototype,"gcc","cd",14)
n(l,"gcg","ci",53)
n(l,"gc8","c9",39)
q(l,"gca",0,1,null,["$2","$1"],["bo","cb"],52,0,0)
n(l,"gbN","bO",5)
m(l,"gbQ","bR",6)
p(l,"gP","R",3)
p(l,"gN","O",3)
m(l=A.cI.prototype,"gaV","aW",6)
p(l,"gP","R",3)
p(l,"gN","O",3)
m(l,"gV","W",0)
m(l=A.cM.prototype,"gaV","aW",6)
p(l,"gP","R",3)
p(l,"gN","O",3)
m(l,"gV","W",0)
n(l=A.cO.prototype,"gbU","bV",46)
q(l,"gce",0,1,null,["$2","$1"],["bp","cf"],11,0,0)
q(l,"gcj",0,1,null,["$2","$1"],["bq","ck"],11,0,0)
q(l,"gc0",0,1,null,["$2","$1"],["bi","c1"],11,0,0)
m(l,"gaK","aL",0)
p(l,"gP","R",3)
p(l,"gN","O",3)
m(l,"gV","W",0)
m(l,"gaM","aN",6)
n(l,"gaS","aq",5)
n(l=A.bk.prototype,"gcv","cw",50)
m(l,"gcP","cQ",1)
m(l,"gcU","cV",1)
o(l,"gB","i",1)
m(l,"gcR","cS",2)
o(A.cG.prototype,"gB","i",1)
o(A.bw.prototype,"gB","i",1)
o(A.cL.prototype,"gB","i",1)
o(A.af.prototype,"gB","i",1)
o(A.cN.prototype,"gB","i",1)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.c,null)
q(A.c,[A.fX,J.ci,J.bc,A.h,A.be,A.x,A.ap,A.r,A.dV,A.aL,A.bn,A.P,A.eI,A.dO,A.bg,A.bN,A.dJ,A.bm,A.cm,A.fm,A.f5,A.d4,A.a0,A.d_,A.fq,A.fo,A.bA,A.ad,A.bD,A.aj,A.C,A.cU,A.d1,A.bS,A.bI,A.o,A.M,A.cc,A.f6,A.cw,A.bv,A.f7,A.di,A.ch,A.G,A.d2,A.cJ,A.dN,A.fk,A.db,A.dI,A.aN,A.d5,A.eX,A.cA,A.O,A.fU,A.cD,A.dm,A.cy,A.aV,A.bk,A.a1,A.dW,A.cG,A.eg,A.ek,A.bw,A.h3,A.cL,A.af,A.eE,A.h4,A.cN])
q(J.ci,[J.cj,J.bi,J.bl,J.aY,J.aZ,J.bj,J.aW])
q(J.bl,[J.av,J.m,A.bo,A.bs])
q(J.av,[J.cB,J.bx,J.L])
r(J.dA,J.m)
q(J.bj,[J.bh,J.ck])
q(A.h,[A.az,A.k,A.aM])
q(A.az,[A.aI,A.bT])
r(A.bE,A.aI)
r(A.bC,A.bT)
r(A.K,A.bC)
q(A.x,[A.aJ,A.ag,A.bG])
q(A.ap,[A.ca,A.c9,A.cK,A.fF,A.fH,A.f_,A.eZ,A.ft,A.fc,A.fj,A.f4,A.fJ,A.fM,A.fN,A.fA,A.eK,A.eL,A.dL,A.eY,A.dd,A.eR,A.eT,A.fK,A.dE,A.dr,A.dq,A.dG,A.dn,A.e3,A.e4,A.e8,A.dZ,A.e_,A.e0,A.e9,A.ea,A.e7,A.e2,A.e1,A.eb,A.ef,A.dv,A.ee,A.dX,A.dY,A.ei,A.ej,A.el])
q(A.ca,[A.da,A.fG,A.fu,A.fy,A.fd,A.dK,A.dM,A.f3,A.eV,A.dB,A.eU,A.eS,A.eQ])
q(A.r,[A.b_,A.ah,A.cn,A.cQ,A.cY,A.cE,A.bd,A.cZ,A.a4,A.by,A.cP,A.b3,A.cb])
q(A.k,[A.w,A.W,A.bH])
r(A.bf,A.aM)
q(A.w,[A.y,A.ay])
r(A.bu,A.ah)
q(A.cK,[A.cH,A.aU])
r(A.cT,A.bd)
q(A.bs,[A.bp,A.b0])
q(A.b0,[A.bJ,A.bL])
r(A.bK,A.bJ)
r(A.bq,A.bK)
r(A.bM,A.bL)
r(A.br,A.bM)
q(A.bq,[A.co,A.cp])
q(A.br,[A.cq,A.cr,A.cs,A.ct,A.cu,A.bt,A.cv])
r(A.bO,A.cZ)
q(A.c9,[A.f0,A.f1,A.fp,A.f8,A.ff,A.fe,A.fb,A.fa,A.f9,A.fi,A.fh,A.fg,A.fx,A.fn,A.dR,A.dS,A.dD,A.dC,A.dT,A.dU,A.dF,A.ds,A.dH,A.dp,A.de,A.df,A.e5,A.e6,A.em,A.en,A.es,A.et,A.ez,A.eA,A.ey,A.eB,A.ex,A.eC,A.ew,A.eD,A.dw,A.dt,A.du,A.ec,A.ed,A.eo,A.ep,A.eq,A.er,A.dx,A.dy,A.dz,A.eF,A.eG,A.eH,A.eu,A.ev])
r(A.aO,A.bD)
r(A.d0,A.bS)
r(A.b4,A.bG)
q(A.a4,[A.b2,A.cg])
r(A.d6,A.d5)
r(A.eW,A.d6)
r(A.cS,A.eW)
r(A.a6,A.eX)
q(A.f6,[A.at,A.R,A.au,A.a_,A.as])
r(A.cl,A.dm)
q(A.cy,[A.cf,A.cF,A.cI,A.cM,A.cO])
s(A.bT,A.o)
s(A.bJ,A.o)
s(A.bK,A.P)
s(A.bL,A.o)
s(A.bM,A.P)
s(A.d5,A.db)
s(A.d6,A.dI)})()
var v={typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{a:"int",q:"double",b9:"num",j:"String",E:"bool",G:"Null",n:"List",c:"Object",S:"Map"},mangledNames:{},types:["~()","j()","c()","~(j,L)","c?()","i(i)","i()","0&()","j(j)","c?(c?)","~(i)","i(c[j?])","~(@)","~(~())","i(c?)","G(@)","~(@,@)","@(@)","E(j,@)","G()","a(a)","G(c)","i(a1)","E(R)","@(j)","G(~())","G(L,L)","~(a,@)","G(c,ac)","E(at)","@(@,j)","C<@>(@)","E(au)","E(a_)","c?(c,c?)","G(@,ac)","~(c?,c?)","a(a,a)","a()","i(m<c?>)","S<j,@>(a1)","E(c,c,c?,c?)","c(c?)","aV?(@)","m<c?>(m<c?>)","j(a1)","~(c?)","E(a6)","j(a)","E(as)","E(i?)","a1(@)","i(c[i?])","i(c)","c(c,ac)"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti")}
A.kq(v.typeUniverse,JSON.parse('{"L":"av","cB":"av","bx":"av","m":{"n":["1"],"k":["1"],"i":[],"h":["1"]},"cj":{"E":[],"p":[]},"bi":{"G":[],"p":[]},"bl":{"i":[]},"av":{"i":[]},"dA":{"m":["1"],"n":["1"],"k":["1"],"i":[],"h":["1"]},"bc":{"aa":["1"]},"bj":{"q":[],"b9":[]},"bh":{"q":[],"a":[],"b9":[],"p":[]},"ck":{"q":[],"b9":[],"p":[]},"aW":{"j":[],"p":[]},"az":{"h":["2"]},"be":{"aa":["2"]},"aI":{"az":["1","2"],"h":["2"],"h.E":"2"},"bE":{"aI":["1","2"],"az":["1","2"],"k":["2"],"h":["2"],"h.E":"2"},"bC":{"o":["2"],"n":["2"],"az":["1","2"],"k":["2"],"h":["2"]},"K":{"bC":["1","2"],"o":["2"],"n":["2"],"az":["1","2"],"k":["2"],"h":["2"],"o.E":"2","h.E":"2"},"aJ":{"x":["3","4"],"S":["3","4"],"x.K":"3","x.V":"4"},"b_":{"r":[]},"k":{"h":["1"]},"w":{"k":["1"],"h":["1"]},"aL":{"aa":["1"]},"aM":{"h":["2"],"h.E":"2"},"bf":{"aM":["1","2"],"k":["2"],"h":["2"],"h.E":"2"},"bn":{"aa":["2"]},"y":{"w":["2"],"k":["2"],"h":["2"],"h.E":"2","w.E":"2"},"ay":{"w":["1"],"k":["1"],"h":["1"],"h.E":"1","w.E":"1"},"bu":{"ah":[],"r":[]},"cn":{"r":[]},"cQ":{"r":[]},"bN":{"ac":[]},"ap":{"aK":[]},"c9":{"aK":[]},"ca":{"aK":[]},"cK":{"aK":[]},"cH":{"aK":[]},"aU":{"aK":[]},"cY":{"r":[]},"cE":{"r":[]},"cT":{"r":[]},"ag":{"x":["1","2"],"hL":["1","2"],"S":["1","2"],"x.K":"1","x.V":"2"},"W":{"k":["1"],"h":["1"],"h.E":"1"},"bm":{"aa":["1"]},"cm":{"jS":[]},"bo":{"i":[],"c8":[],"p":[]},"bs":{"i":[]},"d4":{"c8":[]},"bp":{"fS":[],"i":[],"p":[]},"b0":{"V":["1"],"i":[]},"bq":{"o":["q"],"n":["q"],"V":["q"],"k":["q"],"i":[],"h":["q"],"P":["q"]},"br":{"o":["a"],"n":["a"],"V":["a"],"k":["a"],"i":[],"h":["a"],"P":["a"]},"co":{"dg":[],"o":["q"],"n":["q"],"V":["q"],"k":["q"],"i":[],"h":["q"],"P":["q"],"p":[],"o.E":"q"},"cp":{"dh":[],"o":["q"],"n":["q"],"V":["q"],"k":["q"],"i":[],"h":["q"],"P":["q"],"p":[],"o.E":"q"},"cq":{"dj":[],"o":["a"],"n":["a"],"V":["a"],"k":["a"],"i":[],"h":["a"],"P":["a"],"p":[],"o.E":"a"},"cr":{"dk":[],"o":["a"],"n":["a"],"V":["a"],"k":["a"],"i":[],"h":["a"],"P":["a"],"p":[],"o.E":"a"},"cs":{"dl":[],"o":["a"],"n":["a"],"V":["a"],"k":["a"],"i":[],"h":["a"],"P":["a"],"p":[],"o.E":"a"},"ct":{"eM":[],"o":["a"],"n":["a"],"V":["a"],"k":["a"],"i":[],"h":["a"],"P":["a"],"p":[],"o.E":"a"},"cu":{"eN":[],"o":["a"],"n":["a"],"V":["a"],"k":["a"],"i":[],"h":["a"],"P":["a"],"p":[],"o.E":"a"},"bt":{"eO":[],"o":["a"],"n":["a"],"V":["a"],"k":["a"],"i":[],"h":["a"],"P":["a"],"p":[],"o.E":"a"},"cv":{"eP":[],"o":["a"],"n":["a"],"V":["a"],"k":["a"],"i":[],"h":["a"],"P":["a"],"p":[],"o.E":"a"},"cZ":{"r":[]},"bO":{"ah":[],"r":[]},"C":{"ar":["1"]},"bA":{"dc":["1"]},"ad":{"r":[]},"bD":{"dc":["1"]},"aO":{"bD":["1"],"dc":["1"]},"bS":{"i9":[]},"d0":{"bS":[],"i9":[]},"bG":{"x":["1","2"],"S":["1","2"]},"b4":{"bG":["1","2"],"x":["1","2"],"S":["1","2"],"x.K":"1","x.V":"2"},"bH":{"k":["1"],"h":["1"],"h.E":"1"},"bI":{"aa":["1"]},"x":{"S":["1","2"]},"q":{"b9":[]},"a":{"b9":[]},"n":{"k":["1"],"h":["1"]},"M":{"jb":[]},"bd":{"r":[]},"ah":{"r":[]},"a4":{"r":[]},"b2":{"r":[]},"cg":{"r":[]},"by":{"r":[]},"cP":{"r":[]},"b3":{"r":[]},"cb":{"r":[]},"cw":{"r":[]},"bv":{"r":[]},"ch":{"r":[]},"d2":{"ac":[]},"dl":{"n":["a"],"k":["a"],"h":["a"]},"eP":{"n":["a"],"k":["a"],"h":["a"]},"eO":{"n":["a"],"k":["a"],"h":["a"]},"dj":{"n":["a"],"k":["a"],"h":["a"]},"eM":{"n":["a"],"k":["a"],"h":["a"]},"dk":{"n":["a"],"k":["a"],"h":["a"]},"eN":{"n":["a"],"k":["a"],"h":["a"]},"dg":{"n":["q"],"k":["q"],"h":["q"]},"dh":{"n":["q"],"k":["q"],"h":["q"]}}'))
A.kp(v.typeUniverse,JSON.parse('{"bT":2,"b0":1}'))
var u={c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type",b:"Invalid method parameters: Transaction serialization failed",h:"Please use static method `TronWeb.TRX.sign` for signing with own private key",f:"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAhGVYSWZNTQAqAAAACAAFARIAAwAAAAEAAQAAARoABQAAAAEAAABKARsABQAAAAEAAABSASgAAwAAAAEAAgAAh2kABAAAAAEAAABaAAAAAAAAAEgAAAABAAAASAAAAAEAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAIKADAAQAAAABAAAAIAAAAABfvA/wAAAACXBIWXMAAAsTAAALEwEAmpwYAAACyGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNi4wLjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgICAgICAgICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iPgogICAgICAgICA8dGlmZjpZUmVzb2x1dGlvbj43MjwvdGlmZjpZUmVzb2x1dGlvbj4KICAgICAgICAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+MjwvdGlmZjpSZXNvbHV0aW9uVW5pdD4KICAgICAgICAgPHRpZmY6WFJlc29sdXRpb24+NzI8L3RpZmY6WFJlc29sdXRpb24+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWERpbWVuc2lvbj41MDwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOkNvbG9yU3BhY2U+MTwvZXhpZjpDb2xvclNwYWNlPgogICAgICAgICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+NTA8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KZxgR6QAAB6lJREFUWAnlVmlsXFcZPfe9ecvsYzt2SihSk1SQBUWCqKUJSEkQyw+qSqXEKhKFssROLSTU0MQJAtUI0WYtKkJpYtqoqBJLDAXyB4kSakUlZSkCEtwQoRYqJXU2e+zxvHnztns5903sOBlH6o9KCHGleXPX7zvfud9ygf/3Jm5CgIDiil6d/W/1brJ9wem3Q8aCgudPaog3M2L+vpv22w8rJbB7oAJlGAhtBTsUCFWARw96VKUwNGQAowYeHU3SsRat2BvZbODV1XpdckZgaCAPWzhzMoSU2HlwCkJoTufafAC6TwEPVuDaJyDUOyHRgGE6sIwAnrcR3/jBa3Mn9z2Qzwb5ih6XnMLUxe37vbm1x7+wDLYzili5kEkAAzkocR7K3IBdT1W5r6WLnczcodmOk+VisgSm2QkTnem0lIOp8r4+C8vFRii5AgngZ2So1wM1bWf3PkQ9yVmvjBfRP/w6DvR/F4bYRzktyTEPKI/sXd/aAWCaG3MNwOyiokkk8b3Y+cwJ7N6ynuOPIjFPIxONdKNUtExVqFgWlIrrZ86Nz6CQXWcju8vcu/W4/9VD+7G77/fIGD+nwYu4qQHXuo5+DaUNUYrPJO3a/RPMKt9CCtchmD6QyVpTrlF80i26v+ypVH5V4e8dXYuPfWLN+568f9XaWnj6Fwf8RN7p7u3vw87hlxDLe6mcmgwHzUhTn4pO//lpBxAUAphGk0uD2Hn4BB7bsoW+0ISTPyhyHc/GGfN4T6nQ223ZK0UcL+4yrMXvLvesqJRLvaZj/ubT9ww+N/TetYebSeTNgTCM7bBMH5aiXLYWjBu76bj1GaITDR15Hfv619GR1iPAU8gbLxuuvUb6UXRnpVvcVu4ywjgQPbkibNNQkYxlV66opo3Eqk3X/r7cdj8wdPqVrdmM+Qd/x6HfYVbmPDW6e9VDbpgd/UuV4ZSBWXsQgfU95NWzcJ1Nqu43y5btCEijk3+3FMuiaLlCCIjufMlwbNv0/EbTzueWnPfqK0+/9MzXjZ73fCZZtvYkDjw9cYOWdNh+BWmccy07voEXNIZifAds61Oo+xFj2E3jh3dqCh7l1dJyFJ0s8vzpccYw3LjeiEzH+uT99+y4KwzD03kdObrNyk4HrU87gFVjVx1FrkIkTiJSfVowf0LTVZMJOqnMtR36l8Qlr4bxmUl4QRN2JoOsaSOKY6YdiZlm0IfEO0mGVrTUjbbpa7+Co2NAuZZl+L0fInmD1n8FUvYYUmkcwjZMLCt1IWfZCKIA9cAnC0x+ZMU2LW5VqPp1eGEomioxGD3PX46S23s+vmrM+9qxEN9sQZn9tiFKU6XvVchxyKsuMJl0IpEMBCUUre+2s5zOoBGFDBYLHXRCl4oNXkkjJKCwiZkwEF4QoCFlpysyBYk4nJFWmd6vuZwXAwtlwllokjVBN202f0Uzg9hQyLkuM5/Em14dJgEtrXSjSFAhWfB9D5ONGVQ1K2SkQfO8KGJEU4LOBQu0dgZ0McrmWTSk5Vhihrl8suQ4eFdHj7qtczHLgonppod/1qp4g1T/7cp5XKLSehzhvJ6bmUI9itS0jDAdBpMXkrDOYHMaRjSt/ahl0jUk7QBGeg1s+46vGQ8iFqNInqrT8su1qozjmDfEmKOkDEU1mN/HSfUEHbBGSyXB1QhkIgzkJFm60vBPBQhoBH1k+3NeWjGv6U577QB0SU2bOMMw/BAy5jD9Cpf8umrS6bR3K9J5a2URlhQruCVfhk9QV+gT434D50n/lShQlzmuy2gYifVB3uE/UpFzslsa9LcdQKueA0snR3lwJWT4ZxWGP3E6ylYpV2henKmiQYuTpPUcsDMm7z9OPf/s1GWm+7DpOaaVNPyfwpv4I+laDf/WF1OVs7Kv6V8AgF781ueWo3eEGtSvyetWjFc/Hzb8v/47nHEbcRyVcsV4oj4tz05cUOeql9WFqQn5WvVSzKQUiULOhd88BWvys3A6+hkqLzABxanMeYpnu/PzQMvrH3kgj47CK/jYHQ52HP4xPrJ2BfLualyobgtt83bpWGtCFRuTUUBnEKIpE+FDCuU6hiAdvKcRZCbvRljezPiJMTh8DPsHdjCfHML6pcMYfVW/IVq62Gm/gq6CzSRkM/4ex7f7NmHX94+k+3rKX16EeIv0401TtdoPlRBjTH3jwrHGRSYzhiD4kWqGH4YKv4ioY4BPOhu7hp9mNd0AyD2IKTPIssyzXfUy3V34QSJzLMkkxzJ+RhD3UdAR7PnSXVeU+TCFncllzUca9YTPrKSkXIZIIuuQpoeMpMNxjxAvYPDwy9hL5Yb5fGqw5Luy++qDZM7+BQGUuZ/CNUxDdMAxf4snBnZh28HdOLr5T/hX58ZGqO6DTfaUGSBh3lAsABkmS5hn0Dj7GIZGYxx4aJAidmsrW9lM5NDkA/eG1s6AYN6FOsdKo7NXgynZoVUDdKIR9KaP0uOUcRxPPJyFTtn6OnXi0rljtunaDwwwZi+SnYCM5LjtTYg8ZV/f2hBRqcCe/hKtMuD6Ck0+UgO+bIeG+U5k0yVVV8zNRyUFt25Tn9EJ7NqznPv6cmTPmZOhDRs8XJs7cz2O/96onYEWloXm5/nuWwL8dsh4S4r+tzf9Bwpfgk0+0buPAAAAAElFTkSuQmCC"}
var t=(function rtii(){var s=A.aR
return{n:s("ad"),E:s("c8"),Y:s("fS"),V:s("k<@>"),C:s("r"),W:s("dg"),q:s("dh"),Z:s("aK"),e:s("ar<@>"),h:s("dj"),c8:s("dk"),by:s("dl"),bi:s("h<@>"),bU:s("h<c?>"),O:s("m<i>"),G:s("m<L>"),I:s("m<c>"),s:s("m<j>"),o:s("m<@>"),t:s("m<a>"),c:s("m<c?>"),D:s("a_"),A:s("R"),T:s("bi"),m:s("i"),a6:s("as"),cP:s("at"),c9:s("au"),g:s("L"),da:s("V<@>"),cx:s("n<i>"),u:s("n<L>"),co:s("n<c>"),aY:s("n<j>"),j:s("n<@>"),c1:s("S<j,c>"),aN:s("S<j,j>"),b:s("S<j,@>"),f:s("S<@,@>"),aE:s("S<j,c?>"),P:s("G"),K:s("c"),a:s("O<i>"),ce:s("O<c>"),cY:s("lC"),bd:s("ay<j>"),w:s("ay<a>"),Q:s("a1"),l:s("ac"),N:s("j"),bW:s("p"),b7:s("ah"),c0:s("eM"),bk:s("eN"),ca:s("eO"),bX:s("eP"),cr:s("bx"),k:s("a6"),x:s("aO<i>"),aX:s("C<i>"),d:s("C<@>"),J:s("b4<c?,c?>"),y:s("E"),bG:s("E(c)"),i:s("q"),z:s("@"),cW:s("@()"),v:s("@(c)"),U:s("@(c,ac)"),S:s("a"),L:s("0&*"),_:s("c*"),bc:s("ar<G>?"),r:s("m<c?>?"),B:s("i?"),cV:s("aV?"),X:s("c?"),R:s("O<i>?"),cZ:s("O<c>?"),aD:s("j?"),F:s("aj<@,@>?"),p:s("b9"),H:s("~"),M:s("~()")}})();(function constants(){var s=hunkHelpers.makeConstList
B.S=J.ci.prototype
B.a=J.m.prototype
B.b=J.bh.prototype
B.U=J.bj.prototype
B.m=J.aW.prototype
B.W=J.L.prototype
B.X=J.bl.prototype
B.a2=A.bp.prototype
B.H=J.cB.prototype
B.z=J.bx.prototype
B.B=new A.ch()
B.C=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.L=function() {
  var toStringFunction = Object.prototype.toString;
  function getTag(o) {
    var s = toStringFunction.call(o);
    return s.substring(8, s.length - 1);
  }
  function getUnknownTag(object, tag) {
    if (/^HTML[A-Z].*Element$/.test(tag)) {
      var name = toStringFunction.call(object);
      if (name == "[object Object]") return null;
      return "HTMLElement";
    }
  }
  function getUnknownTagGenericBrowser(object, tag) {
    if (object instanceof HTMLElement) return "HTMLElement";
    return getUnknownTag(object, tag);
  }
  function prototypeForTag(tag) {
    if (typeof window == "undefined") return null;
    if (typeof window[tag] == "undefined") return null;
    var constructor = window[tag];
    if (typeof constructor != "function") return null;
    return constructor.prototype;
  }
  function discriminator(tag) { return null; }
  var isBrowser = typeof HTMLElement == "function";
  return {
    getTag: getTag,
    getUnknownTag: isBrowser ? getUnknownTagGenericBrowser : getUnknownTag,
    prototypeForTag: prototypeForTag,
    discriminator: discriminator };
}
B.Q=function(getTagFallback) {
  return function(hooks) {
    if (typeof navigator != "object") return hooks;
    var userAgent = navigator.userAgent;
    if (typeof userAgent != "string") return hooks;
    if (userAgent.indexOf("DumpRenderTree") >= 0) return hooks;
    if (userAgent.indexOf("Chrome") >= 0) {
      function confirm(p) {
        return typeof window == "object" && window[p] && window[p].name == p;
      }
      if (confirm("Window") && confirm("HTMLElement")) return hooks;
    }
    hooks.getTag = getTagFallback;
  };
}
B.M=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.P=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Firefox") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "GeoGeolocation": "Geolocation",
    "Location": "!Location",
    "WorkerMessageEvent": "MessageEvent",
    "XMLDocument": "!Document"};
  function getTagFirefox(o) {
    var tag = getTag(o);
    return quickMap[tag] || tag;
  }
  hooks.getTag = getTagFirefox;
}
B.O=function(hooks) {
  if (typeof navigator != "object") return hooks;
  var userAgent = navigator.userAgent;
  if (typeof userAgent != "string") return hooks;
  if (userAgent.indexOf("Trident/") == -1) return hooks;
  var getTag = hooks.getTag;
  var quickMap = {
    "BeforeUnloadEvent": "Event",
    "DataTransfer": "Clipboard",
    "HTMLDDElement": "HTMLElement",
    "HTMLDTElement": "HTMLElement",
    "HTMLPhraseElement": "HTMLElement",
    "Position": "Geoposition"
  };
  function getTagIE(o) {
    var tag = getTag(o);
    var newTag = quickMap[tag];
    if (newTag) return newTag;
    if (tag == "Object") {
      if (window.DataView && (o instanceof window.DataView)) return "DataView";
    }
    return tag;
  }
  function prototypeForTagIE(tag) {
    var constructor = window[tag];
    if (constructor == null) return null;
    return constructor.prototype;
  }
  hooks.getTag = getTagIE;
  hooks.prototypeForTag = prototypeForTagIE;
}
B.N=function(hooks) {
  var getTag = hooks.getTag;
  var prototypeForTag = hooks.prototypeForTag;
  function getTagFixed(o) {
    var tag = getTag(o);
    if (tag == "Document") {
      if (!!o.xmlVersion) return "!Document";
      return "!HTMLDocument";
    }
    return tag;
  }
  function prototypeForTagFixed(tag) {
    if (tag == "Document") return null;
    return prototypeForTag(tag);
  }
  hooks.getTag = getTagFixed;
  hooks.prototypeForTag = prototypeForTagFixed;
}
B.D=function(hooks) { return hooks; }

B.R=new A.cw()
B.ah=new A.dV()
B.c=new A.d0()
B.o=new A.d2()
B.av=A.d(s([151]),t.t)
B.r=new A.a_("ethereum")
B.ax=A.d(s([153]),t.t)
B.t=new A.a_("solana")
B.az=A.d(s([155]),t.t)
B.u=new A.a_("stellar")
B.ay=A.d(s([154]),t.t)
B.v=new A.a_("ton")
B.aw=A.d(s([152]),t.t)
B.w=new A.a_("tron")
B.ak=A.d(s([110]),t.t)
B.d=new A.R("accountsChanged")
B.ap=A.d(s([115]),t.t)
B.j=new A.R("active")
B.al=A.d(s([111]),t.t)
B.e=new A.R("chainChanged")
B.ar=A.d(s([117]),t.t)
B.i=new A.R("change")
B.an=A.d(s([113]),t.t)
B.f=new A.R("connect")
B.aq=A.d(s([116]),t.t)
B.k=new A.R("disable")
B.ao=A.d(s([114]),t.t)
B.h=new A.R("disconnect")
B.am=A.d(s([112]),t.t)
B.l=new A.R("message")
B.x=new A.as("web3")
B.E=new A.as("walletAdapter")
B.ai=A.d(s([100]),t.t)
B.F=new A.at("response")
B.at=A.d(s([131]),t.t)
B.p=new A.au("failed")
B.as=A.d(s([130]),t.t)
B.y=new A.au("success")
B.Y=A.d(s([B.x,B.E]),A.aR("m<as>"))
B.Z=A.d(s([B.y,B.p]),A.aR("m<au>"))
B.au=A.d(s([150]),t.t)
B.T=new A.a_("global")
B.a0=A.d(s([B.T,B.r,B.w,B.t,B.v,B.u]),A.aR("m<a_>"))
B.G=A.d(s([B.d,B.e,B.l,B.f,B.h,B.j,B.k,B.i]),A.aR("m<R>"))
B.aj=A.d(s([101]),t.t)
B.V=new A.at("event")
B.a1=A.d(s([B.F,B.V]),A.aR("m<at>"))
B.a3=A.a8("c8")
B.a4=A.a8("fS")
B.a5=A.a8("dg")
B.a6=A.a8("dh")
B.a7=A.a8("dj")
B.a8=A.a8("dk")
B.a9=A.a8("dl")
B.aa=A.a8("c")
B.ab=A.a8("eM")
B.ac=A.a8("eN")
B.ad=A.a8("eO")
B.ae=A.a8("eP")
B.n=new A.aN("An error occurred during the request",-32603,"WALLET-000",null)
B.I=new A.aN("The requested method does not exist. Please check the method name and try again.",4200,"WEB3-4030",null)
B.a_=A.d(s(["eth_requestAccounts"]),t.s)
B.af=new A.a6("solana_requestAccounts",B.a_)
B.q=A.d(s([]),t.s)
B.A=new A.a6("solana_sendTransaction",B.q)
B.ag=new A.a6("solana_signMessage",B.q)
B.J=new A.a6("solana_signTransaction",B.q)
B.K=new A.a6("solana_signAllTransactions",B.q)})();(function staticFields(){$.fl=null
$.Y=A.d([],t.I)
$.hQ=null
$.hy=null
$.hx=null
$.iL=null
$.iH=null
$.iO=null
$.fC=null
$.fI=null
$.hm=null
$.b5=null
$.bX=null
$.bY=null
$.hj=!1
$.v=B.c
$.ic=null
$.id=null
$.ie=null
$.ig=null
$.h5=A.cX("_lastQuoRemDigits")
$.h6=A.cX("_lastQuoRemUsed")
$.bB=A.cX("_lastRemUsed")
$.h7=A.cX("_lastRem_nsh")
$.jZ=A.d([B.af,B.J,B.K,B.A,B.ag],A.aR("m<a6>"))
$.cz=A.cX("_walletId")
$.dP=A.hM(t.N,A.aR("cA"))})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal,r=hunkHelpers.lazy
s($,"lz","c4",()=>A.li("_$dart_dartClosure"))
s($,"lH","iV",()=>A.ai(A.eJ({
toString:function(){return"$receiver$"}})))
s($,"lI","iW",()=>A.ai(A.eJ({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"lJ","iX",()=>A.ai(A.eJ(null)))
s($,"lK","iY",()=>A.ai(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(q){return q.message}}()))
s($,"lN","j0",()=>A.ai(A.eJ(void 0)))
s($,"lO","j1",()=>A.ai(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(q){return q.message}}()))
s($,"lM","j_",()=>A.ai(A.i5(null)))
s($,"lL","iZ",()=>A.ai(function(){try{null.$method$}catch(q){return q.message}}()))
s($,"lQ","j3",()=>A.ai(A.i5(void 0)))
s($,"lP","j2",()=>A.ai(function(){try{(void 0).$method$}catch(q){return q.message}}()))
s($,"lR","hr",()=>A.k_())
s($,"lW","ao",()=>A.cV(0))
s($,"lV","d9",()=>A.cV(1))
s($,"lT","ht",()=>$.d9().K(0))
s($,"lS","hs",()=>A.cV(1e4))
r($,"lU","j4",()=>A.jT("^\\s*([+-]?)((0x[a-f0-9]+)|(\\d+)|([a-z0-9]+))\\s*$",!1))
s($,"m6","j5",()=>A.d8(B.aa))
s($,"lB","iR",()=>{var q=new A.fk(new DataView(new ArrayBuffer(A.kD(8))))
q.bJ()
return q})
s($,"lA","fO",()=>({uuid:"466aef37-e077-42d1-b26b-801ff1af4a36",name:"MRT",icon:u.f,rdns:"com.mrtnetwork.wallet"}))
s($,"lE","iT",()=>A.fZ(A.d(["legacy",A.jC(0)],t.I),t.K))
s($,"lD","iS",()=>A.fZ(A.d(["solana:signAndSendTransaction","solana:signTransaction","solana:signMessage","solana:signIn"],t.s),t.N))
s($,"lF","iU",()=>A.fZ(A.d(["solana:mainnet","solana:devnet","solana:testnet"],t.s),t.N))})();(function nativeSupport(){!function(){var s=function(a){var m={}
m[a]=1
return Object.keys(hunkHelpers.convertToFastObject(m))[0]}
v.getIsolateTag=function(a){return s("___dart_"+a+v.isolateTag)}
var r="___dart_isolate_tags_"
var q=Object[r]||(Object[r]=Object.create(null))
var p="_ZxYxX"
for(var o=0;;o++){var n=s(p+"_"+o+"_")
if(!(n in q)){q[n]=1
v.isolateTag=n
break}}v.dispatchPropertyName=v.getIsolateTag("dispatch_record")}()
hunkHelpers.setOrUpdateInterceptorsByTag({ArrayBuffer:A.bo,ArrayBufferView:A.bs,DataView:A.bp,Float32Array:A.co,Float64Array:A.cp,Int16Array:A.cq,Int32Array:A.cr,Int8Array:A.cs,Uint16Array:A.ct,Uint32Array:A.cu,Uint8ClampedArray:A.bt,CanvasPixelArray:A.bt,Uint8Array:A.cv})
hunkHelpers.setOrUpdateLeafTags({ArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.b0.$nativeSuperclassTag="ArrayBufferView"
A.bJ.$nativeSuperclassTag="ArrayBufferView"
A.bK.$nativeSuperclassTag="ArrayBufferView"
A.bq.$nativeSuperclassTag="ArrayBufferView"
A.bL.$nativeSuperclassTag="ArrayBufferView"
A.bM.$nativeSuperclassTag="ArrayBufferView"
A.br.$nativeSuperclassTag="ArrayBufferView"})()
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$0=function(){return this()}
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$1$1=function(a){return this(a)}
Function.prototype.$1$0=function(){return this()}
Function.prototype.$2$0=function(){return this()}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var s=document.scripts
function onLoad(b){for(var q=0;q<s.length;++q){s[q].removeEventListener("load",onLoad,false)}a(b.target)}for(var r=0;r<s.length;++r){s[r].addEventListener("load",onLoad,false)}})(function(a){v.currentScript=a
var s=function(b){return A.ho(A.le(b))}
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()