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
if(a[b]!==s){A.c1(b)}a[b]=r}var q=a[b]
a[c]=function(){return q}
return q}}function makeConstList(a){a.$flags=7
return a}function convertToFastObject(a){function t(){}t.prototype=a
new t()
return a}function convertAllToFastObject(a){for(var s=0;s<a.length;++s){convertToFastObject(a[s])}}var y=0
function instanceTearOffGetter(a,b){var s=null
return a?function(c){if(s===null)s=A.fF(b)
return new s(c,this)}:function(){if(s===null)s=A.fF(b)
return new s(this,null)}}function staticTearOffGetter(a){var s=null
return function(){if(s===null)s=A.fF(a).prototype
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
fK(a,b,c,d){return{i:a,p:b,e:c,x:d}},
f_(a){var s,r,q,p,o,n=a[v.dispatchPropertyName]
if(n==null)if($.fH==null){A.kg()
n=a[v.dispatchPropertyName]}if(n!=null){s=n.p
if(!1===s)return n.i
if(!0===s)return a
r=Object.getPrototypeOf(a)
if(s===r)return n.i
if(n.e===r)throw A.d(A.fq("Return interceptor for "+A.w(s(a,n))))}q=a.constructor
if(q==null)p=null
else{o=$.eJ
if(o==null)o=$.eJ=v.getIsolateTag("_$dart_js")
p=q[o]}if(p!=null)return p
p=A.kl(a)
if(p!=null)return p
if(typeof a=="function")return B.a0
s=Object.getPrototypeOf(a)
if(s==null)return B.P
if(s===Object.prototype)return B.P
if(typeof q=="function"){o=$.eJ
if(o==null)o=$.eJ=v.getIsolateTag("_$dart_js")
Object.defineProperty(q,o,{value:B.H,enumerable:false,writable:true,configurable:true})
return B.H}return B.H},
iA(a,b){if(a<0||a>4294967295)throw A.d(A.aE(a,0,4294967295,"length",null))
return J.iB(new Array(a),b)},
fX(a,b){if(a<0)throw A.d(A.a7("Length must be a non-negative integer: "+a,null))
return A.a(new Array(a),b.h("l<0>"))},
iB(a,b){var s=A.a(a,b.h("l<0>"))
s.$flags=1
return s},
aJ(a){if(typeof a=="number"){if(Math.floor(a)==a)return J.bf.prototype
return J.cf.prototype}if(typeof a=="string")return J.aL.prototype
if(a==null)return J.bg.prototype
if(typeof a=="boolean")return J.ce.prototype
if(Array.isArray(a))return J.l.prototype
if(typeof a!="object"){if(typeof a=="function")return J.z.prototype
if(typeof a=="symbol")return J.aN.prototype
if(typeof a=="bigint")return J.aM.prototype
return a}if(a instanceof A.b)return a
return J.f_(a)},
hO(a){if(typeof a=="string")return J.aL.prototype
if(a==null)return a
if(Array.isArray(a))return J.l.prototype
if(typeof a!="object"){if(typeof a=="function")return J.z.prototype
if(typeof a=="symbol")return J.aN.prototype
if(typeof a=="bigint")return J.aM.prototype
return a}if(a instanceof A.b)return a
return J.f_(a)},
bZ(a){if(a==null)return a
if(Array.isArray(a))return J.l.prototype
if(typeof a!="object"){if(typeof a=="function")return J.z.prototype
if(typeof a=="symbol")return J.aN.prototype
if(typeof a=="bigint")return J.aM.prototype
return a}if(a instanceof A.b)return a
return J.f_(a)},
kc(a){if(a==null)return a
if(typeof a!="object"){if(typeof a=="function")return J.z.prototype
if(typeof a=="symbol")return J.aN.prototype
if(typeof a=="bigint")return J.aM.prototype
return a}if(a instanceof A.b)return a
return J.f_(a)},
fb(a,b){if(a==null)return b==null
if(typeof a!="object")return b!=null&&a===b
return J.aJ(a).S(a,b)},
ib(a,b){if(typeof b==="number")if(Array.isArray(a)||A.kk(a,a[v.dispatchPropertyName]))if(b>>>0===b&&b<a.length)return a[b]
return J.bZ(a).j(a,b)},
ic(a,b,c){return J.kc(a).bu(a,b,c)},
fN(a,b){return J.bZ(a).P(a,b)},
a5(a){return J.aJ(a).gt(a)},
b3(a){return J.bZ(a).gB(a)},
cT(a){return J.hO(a).gp(a)},
id(a){return J.aJ(a).gu(a)},
cU(a,b,c){return J.bZ(a).aw(a,b,c)},
b4(a){return J.aJ(a).i(a)},
cd:function cd(){},
ce:function ce(){},
bg:function bg(){},
x:function x(){},
au:function au(){},
cw:function cw(){},
bB:function bB(){},
z:function z(){},
aM:function aM(){},
aN:function aN(){},
l:function l(a){this.$ti=a},
dy:function dy(a){this.$ti=a},
b6:function b6(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
cg:function cg(){},
bf:function bf(){},
cf:function cf(){},
aL:function aL(){}},A={fi:function fi(){},
av(a,b){a=a+b&536870911
a=a+((a&524287)<<10)&536870911
return a^a>>>6},
fo(a){a=a+((a&67108863)<<3)&536870911
a^=a>>>11
return a+((a&16383)<<15)&536870911},
eV(a,b,c){return a},
fI(a){var s,r
for(s=$.S.length,r=0;r<s;++r)if(a===$.S[r])return!0
return!1},
iM(a,b,c,d){if(t.V.b(a))return new A.bb(a,b,c.h("@<0>").n(d).h("bb<1,2>"))
return new A.aD(a,b,c.h("@<0>").n(d).h("aD<1,2>"))},
iu(){return new A.aT("No element")},
aU:function aU(){},
b9:function b9(a,b){this.a=a
this.$ti=b},
bF:function bF(){},
a9:function a9(a,b){this.a=a
this.$ti=b},
cj:function cj(a){this.a=a},
dV:function dV(){},
j:function j(){},
G:function G(){},
aC:function aC(a,b,c){var _=this
_.a=a
_.b=b
_.c=0
_.d=null
_.$ti=c},
aD:function aD(a,b,c){this.a=a
this.b=b
this.$ti=c},
bb:function bb(a,b,c){this.a=a
this.b=b
this.$ti=c},
bm:function bm(a,b,c){var _=this
_.a=null
_.b=a
_.c=b
_.$ti=c},
M:function M(a,b,c){this.a=a
this.b=b
this.$ti=c},
K:function K(){},
bV:function bV(){},
hW(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
kk(a,b){var s
if(b!=null){s=b.x
if(s!=null)return s}return t.da.b(a)},
w(a){var s
if(typeof a=="string")return a
if(typeof a=="number"){if(a!==0)return""+a}else if(!0===a)return"true"
else if(!1===a)return"false"
else if(a==null)return"null"
s=J.b4(a)
return s},
cx(a){var s,r=$.h7
if(r==null)r=$.h7=Symbol("identityHashCode")
s=a[r]
if(s==null){s=Math.random()*0x3fffffff|0
a[r]=s}return s},
dQ(a){return A.iP(a)},
iP(a){var s,r,q,p
if(a instanceof A.b)return A.I(A.b0(a),null)
s=J.aJ(a)
if(s===B.X||s===B.a1||t.cr.b(a)){r=B.J(a)
if(r!=="Object"&&r!=="")return r
q=a.constructor
if(typeof q=="function"){p=q.name
if(typeof p=="string"&&p!=="Object"&&p!=="")return p}}return A.I(A.b0(a),null)},
iY(a){if(a==null||typeof a=="number"||A.eR(a))return J.b4(a)
if(typeof a=="string")return JSON.stringify(a)
if(a instanceof A.ap)return a.i(0)
if(a instanceof A.cJ)return a.dR(!0)
return"Instance of '"+A.dQ(a)+"'"},
aR(a){if(a.date===void 0)a.date=new Date(a.a)
return a.date},
iX(a){var s=A.aR(a).getUTCFullYear()+0
return s},
iV(a){var s=A.aR(a).getUTCMonth()+1
return s},
iR(a){var s=A.aR(a).getUTCDate()+0
return s},
iS(a){var s=A.aR(a).getUTCHours()+0
return s},
iU(a){var s=A.aR(a).getUTCMinutes()+0
return s},
iW(a){var s=A.aR(a).getUTCSeconds()+0
return s},
iT(a){var s=A.aR(a).getUTCMilliseconds()+0
return s},
iQ(a){var s=a.$thrownJsError
if(s==null)return null
return A.az(s)},
h8(a,b){var s
if(a.$thrownJsError==null){s=A.d(a)
a.$thrownJsError=s
s.stack=b.i(0)}},
J(a,b){if(a==null)J.cT(a)
throw A.d(A.eY(a,b))},
eY(a,b){var s,r="index"
if(!A.hC(b))return new A.a6(!0,b,r,null)
s=J.cT(a)
if(b<0||b>=s)return A.fV(b,s,a,r)
return new A.aS(null,null,!0,b,r,"Value not in range")},
d(a){return A.hQ(new Error(),a)},
hQ(a,b){var s
if(b==null)b=new A.af()
a.dartException=b
s=A.kq
if("defineProperty" in Object){Object.defineProperty(a,"message",{get:s})
a.name=""}else a.toString=s
return a},
kq(){return J.b4(this.dartException)},
an(a){throw A.d(a)},
hV(a,b){throw A.hQ(b,a)},
cS(a,b,c){var s
if(b==null)b=0
if(c==null)c=0
s=Error()
A.hV(A.jy(a,b,c),s)},
jy(a,b,c){var s,r,q,p,o,n,m,l,k
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
return new A.bC("'"+s+"': Cannot "+o+" "+l+k+n)},
c0(a){throw A.d(A.aq(a))},
ag(a){var s,r,q,p,o,n
a=A.ko(a.replace(String({}),"$receiver$"))
s=a.match(/\\\$[a-zA-Z]+\\\$/g)
if(s==null)s=A.a([],t.s)
r=s.indexOf("\\$arguments\\$")
q=s.indexOf("\\$argumentsExpr\\$")
p=s.indexOf("\\$expr\\$")
o=s.indexOf("\\$method\\$")
n=s.indexOf("\\$receiver\\$")
return new A.e7(a.replace(new RegExp("\\\\\\$arguments\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$argumentsExpr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$expr\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$method\\\\\\$","g"),"((?:x|[^x])*)").replace(new RegExp("\\\\\\$receiver\\\\\\$","g"),"((?:x|[^x])*)"),r,q,p,o,n)},
e8(a){return function($expr$){var $argumentsExpr$="$arguments$"
try{$expr$.$method$($argumentsExpr$)}catch(s){return s.message}}(a)},
hg(a){return function($expr$){try{$expr$.$method$}catch(s){return s.message}}(a)},
fj(a,b){var s=b==null,r=s?null:b.method
return new A.ci(a,r,s?null:b.receiver)},
ao(a){var s
if(a==null)return new A.dP(a)
if(a instanceof A.bd){s=a.a
return A.aA(a,s==null?t.K.a(s):s)}if(typeof a!=="object")return a
if("dartException" in a)return A.aA(a,a.dartException)
return A.k1(a)},
aA(a,b){if(t.C.b(b))if(b.$thrownJsError==null)b.$thrownJsError=a
return b},
k1(a){var s,r,q,p,o,n,m,l,k,j,i,h,g
if(!("message" in a))return a
s=a.message
if("number" in a&&typeof a.number=="number"){r=a.number
q=r&65535
if((B.f.cS(r,16)&8191)===10)switch(q){case 438:return A.aA(a,A.fj(A.w(s)+" (Error "+q+")",null))
case 445:case 5007:A.w(s)
return A.aA(a,new A.bt())}}if(a instanceof TypeError){p=$.i0()
o=$.i1()
n=$.i2()
m=$.i3()
l=$.i6()
k=$.i7()
j=$.i5()
$.i4()
i=$.i9()
h=$.i8()
g=p.O(s)
if(g!=null)return A.aA(a,A.fj(A.h(s),g))
else{g=o.O(s)
if(g!=null){g.method="call"
return A.aA(a,A.fj(A.h(s),g))}else if(n.O(s)!=null||m.O(s)!=null||l.O(s)!=null||k.O(s)!=null||j.O(s)!=null||m.O(s)!=null||i.O(s)!=null||h.O(s)!=null){A.h(s)
return A.aA(a,new A.bt())}}return A.aA(a,new A.cD(typeof s=="string"?s:""))}if(a instanceof RangeError){if(typeof s=="string"&&s.indexOf("call stack")!==-1)return new A.bv()
s=function(b){try{return String(b)}catch(f){}return null}(a)
return A.aA(a,new A.a6(!1,null,null,typeof s=="string"?s.replace(/^RangeError:\s*/,""):s))}if(typeof InternalError=="function"&&a instanceof InternalError)if(typeof s=="string"&&s==="too much recursion")return new A.bv()
return a},
az(a){var s
if(a instanceof A.bd)return a.b
if(a==null)return new A.bN(a)
s=a.$cachedTrace
if(s!=null)return s
s=new A.bN(a)
if(typeof a==="object")a.$cachedTrace=s
return s},
cR(a){if(a==null)return J.a5(a)
if(typeof a=="object")return A.cx(a)
return J.a5(a)},
kb(a,b){var s,r,q,p=a.length
for(s=0;s<p;s=q){r=s+1
q=r+1
b.C(0,a[s],a[r])}return b},
jI(a,b,c,d,e,f){t.Z.a(a)
switch(A.a3(b)){case 0:return a.$0()
case 1:return a.$1(c)
case 2:return a.$2(c,d)
case 3:return a.$3(c,d,e)
case 4:return a.$4(c,d,e,f)}throw A.d(new A.eq("Unsupported number of arguments for wrapped closure"))},
bY(a,b){var s=a.$identity
if(!!s)return s
s=A.k7(a,b)
a.$identity=s
return s},
k7(a,b){var s
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
return function(c,d,e){return function(f,g,h,i){return e(c,d,f,g,h,i)}}(a,b,A.jI)},
il(a2){var s,r,q,p,o,n,m,l,k,j,i=a2.co,h=a2.iS,g=a2.iI,f=a2.nDA,e=a2.aI,d=a2.fs,c=a2.cs,b=d[0],a=c[0],a0=i[b],a1=a2.fT
a1.toString
s=h?Object.create(new A.cz().constructor.prototype):Object.create(new A.aK(null,null).constructor.prototype)
s.$initialize=s.constructor
r=h?function static_tear_off(){this.$initialize()}:function tear_off(a3,a4){this.$initialize(a3,a4)}
s.constructor=r
r.prototype=s
s.$_name=b
s.$_target=a0
q=!h
if(q)p=A.fS(b,a0,g,f)
else{s.$static_name=b
p=a0}s.$S=A.ih(a1,h,g)
s[a]=p
for(o=p,n=1;n<d.length;++n){m=d[n]
if(typeof m=="string"){l=i[m]
k=m
m=l}else k=""
j=c[n]
if(j!=null){if(q)m=A.fS(k,m,g,f)
s[j]=m}if(n===e)o=m}s.$C=o
s.$R=a2.rC
s.$D=a2.dV
return r},
ih(a,b,c){if(typeof a=="number")return a
if(typeof a=="string"){if(b)throw A.d("Cannot compute signature for static tearoff.")
return function(d,e){return function(){return e(this,d)}}(a,A.ie)}throw A.d("Error in functionType of tearoff")},
ii(a,b,c,d){var s=A.fR
switch(b?-1:a){case 0:return function(e,f){return function(){return f(this)[e]()}}(c,s)
case 1:return function(e,f){return function(g){return f(this)[e](g)}}(c,s)
case 2:return function(e,f){return function(g,h){return f(this)[e](g,h)}}(c,s)
case 3:return function(e,f){return function(g,h,i){return f(this)[e](g,h,i)}}(c,s)
case 4:return function(e,f){return function(g,h,i,j){return f(this)[e](g,h,i,j)}}(c,s)
case 5:return function(e,f){return function(g,h,i,j,k){return f(this)[e](g,h,i,j,k)}}(c,s)
default:return function(e,f){return function(){return e.apply(f(this),arguments)}}(d,s)}},
fS(a,b,c,d){if(c)return A.ik(a,b,d)
return A.ii(b.length,d,a,b)},
ij(a,b,c,d){var s=A.fR,r=A.ig
switch(b?-1:a){case 0:throw A.d(new A.cy("Intercepted function with no arguments."))
case 1:return function(e,f,g){return function(){return f(this)[e](g(this))}}(c,r,s)
case 2:return function(e,f,g){return function(h){return f(this)[e](g(this),h)}}(c,r,s)
case 3:return function(e,f,g){return function(h,i){return f(this)[e](g(this),h,i)}}(c,r,s)
case 4:return function(e,f,g){return function(h,i,j){return f(this)[e](g(this),h,i,j)}}(c,r,s)
case 5:return function(e,f,g){return function(h,i,j,k){return f(this)[e](g(this),h,i,j,k)}}(c,r,s)
case 6:return function(e,f,g){return function(h,i,j,k,l){return f(this)[e](g(this),h,i,j,k,l)}}(c,r,s)
default:return function(e,f,g){return function(){var q=[g(this)]
Array.prototype.push.apply(q,arguments)
return e.apply(f(this),q)}}(d,r,s)}},
ik(a,b,c){var s,r
if($.fP==null)$.fP=A.fO("interceptor")
if($.fQ==null)$.fQ=A.fO("receiver")
s=b.length
r=A.ij(s,c,a,b)
return r},
fF(a){return A.il(a)},
ie(a,b){return A.bT(v.typeUniverse,A.b0(a.a),b)},
fR(a){return a.a},
ig(a){return a.b},
fO(a){var s,r,q,p=new A.aK("receiver","interceptor"),o=Object.getOwnPropertyNames(p)
o.$flags=1
s=o
for(o=s.length,r=0;r<o;++r){q=s[r]
if(p[q]===a)return q}throw A.d(A.a7("Field name "+a+" not found.",null))},
hM(a){if(a==null)A.k2("boolean expression must not be null")
return a},
k2(a){throw A.d(new A.cE(a))},
kX(a){throw A.d(new A.cG(a))},
kd(a){return v.getIsolateTag(a)},
k8(a){var s,r=A.a([],t.s)
if(a==null)return r
if(Array.isArray(a)){for(s=0;s<a.length;++s)r.push(String(a[s]))
return r}r.push(String(a))
return r},
kW(a,b,c){Object.defineProperty(a,b,{value:c,enumerable:false,writable:true,configurable:true})},
kl(a){var s,r,q,p,o,n=A.h($.hP.$1(a)),m=$.eZ[n]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.f3[n]
if(s!=null)return s
r=v.interceptorsByTag[n]
if(r==null){q=A.ak($.hK.$2(a,n))
if(q!=null){m=$.eZ[q]
if(m!=null){Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}s=$.f3[q]
if(s!=null)return s
r=v.interceptorsByTag[q]
n=q}}if(r==null)return null
s=r.prototype
p=n[0]
if(p==="!"){m=A.f7(s)
$.eZ[n]=m
Object.defineProperty(a,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
return m.i}if(p==="~"){$.f3[n]=s
return s}if(p==="-"){o=A.f7(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}if(p==="+")return A.hS(a,s)
if(p==="*")throw A.d(A.fq(n))
if(v.leafTags[n]===true){o=A.f7(s)
Object.defineProperty(Object.getPrototypeOf(a),v.dispatchPropertyName,{value:o,enumerable:false,writable:true,configurable:true})
return o.i}else return A.hS(a,s)},
hS(a,b){var s=Object.getPrototypeOf(a)
Object.defineProperty(s,v.dispatchPropertyName,{value:J.fK(b,s,null,null),enumerable:false,writable:true,configurable:true})
return b},
f7(a){return J.fK(a,!1,null,!!a.$iQ)},
kn(a,b,c){var s=b.prototype
if(v.leafTags[a]===true)return A.f7(s)
else return J.fK(s,c,null,null)},
kg(){if(!0===$.fH)return
$.fH=!0
A.kh()},
kh(){var s,r,q,p,o,n,m,l
$.eZ=Object.create(null)
$.f3=Object.create(null)
A.kf()
s=v.interceptorsByTag
r=Object.getOwnPropertyNames(s)
if(typeof window!="undefined"){window
q=function(){}
for(p=0;p<r.length;++p){o=r[p]
n=$.hU.$1(o)
if(n!=null){m=A.kn(o,s[o],n)
if(m!=null){Object.defineProperty(n,v.dispatchPropertyName,{value:m,enumerable:false,writable:true,configurable:true})
q.prototype=n}}}}for(p=0;p<r.length;++p){o=r[p]
if(/^[A-Za-z_]/.test(o)){l=s[o]
s["!"+o]=l
s["~"+o]=l
s["-"+o]=l
s["+"+o]=l
s["*"+o]=l}}},
kf(){var s,r,q,p,o,n,m=B.Q()
m=A.b_(B.R,A.b_(B.S,A.b_(B.K,A.b_(B.K,A.b_(B.T,A.b_(B.U,A.b_(B.V(B.J),m)))))))
if(typeof dartNativeDispatchHooksTransformer!="undefined"){s=dartNativeDispatchHooksTransformer
if(typeof s=="function")s=[s]
if(Array.isArray(s))for(r=0;r<s.length;++r){q=s[r]
if(typeof q=="function")m=q(m)||m}}p=m.getTag
o=m.getUnknownTag
n=m.prototypeForTag
$.hP=new A.f0(p)
$.hK=new A.f1(o)
$.hU=new A.f2(n)},
b_(a,b){return a(b)||b},
k9(a,b){var s=b.length,r=v.rttc[""+s+";"+a]
if(r==null)return null
if(s===0)return r
if(s===r.length)return r.apply(null,b)
return r(b)},
ko(a){if(/[[\]{}()*+?.\\^$|]/.test(a))return a.replace(/[[\]{}()*+?.\\^$|]/g,"\\$&")
return a},
e7:function e7(a,b,c,d,e,f){var _=this
_.a=a
_.b=b
_.c=c
_.d=d
_.e=e
_.f=f},
bt:function bt(){},
ci:function ci(a,b,c){this.a=a
this.b=b
this.c=c},
cD:function cD(a){this.a=a},
dP:function dP(a){this.a=a},
bd:function bd(a,b){this.a=a
this.b=b},
bN:function bN(a){this.a=a
this.b=null},
ap:function ap(){},
c4:function c4(){},
c5:function c5(){},
cB:function cB(){},
cz:function cz(){},
aK:function aK(a,b){this.a=a
this.b=b},
cG:function cG(a){this.a=a},
cy:function cy(a){this.a=a},
cE:function cE(a){this.a=a},
aa:function aa(a){var _=this
_.a=0
_.f=_.e=_.d=_.c=_.b=null
_.r=0
_.$ti=a},
dK:function dK(a,b){var _=this
_.a=a
_.b=b
_.d=_.c=null},
bl:function bl(a,b){this.a=a
this.$ti=b},
bk:function bk(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
bi:function bi(a,b){this.a=a
this.$ti=b},
bj:function bj(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=null
_.$ti=d},
f0:function f0(a){this.a=a},
f1:function f1(a){this.a=a},
f2:function f2(a){this.a=a},
cJ:function cJ(){},
iN(a,b,c){var s=new Uint8Array(a,b,c)
return s},
aG(a,b,c){if(a>>>0!==a||a>=c)throw A.d(A.eY(b,a))},
bn:function bn(){},
br:function br(){},
cO:function cO(a){this.a=a},
bo:function bo(){},
aP:function aP(){},
bp:function bp(){},
bq:function bq(){},
ck:function ck(){},
cl:function cl(){},
cm:function cm(){},
cn:function cn(){},
co:function co(){},
cp:function cp(){},
cq:function cq(){},
bs:function bs(){},
cr:function cr(){},
bJ:function bJ(){},
bK:function bK(){},
bL:function bL(){},
bM:function bM(){},
ha(a,b){var s=b.c
return s==null?b.c=A.fy(a,b.x,!0):s},
fm(a,b){var s=b.c
return s==null?b.c=A.bR(a,"F",[b.x]):s},
hb(a){var s=a.w
if(s===6||s===7||s===8)return A.hb(a.x)
return s===12||s===13},
j1(a){return a.as},
aI(a){return A.cN(v.typeUniverse,a,!1)},
ay(a1,a2,a3,a4){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0=a2.w
switch(a0){case 5:case 1:case 2:case 3:case 4:return a2
case 6:s=a2.x
r=A.ay(a1,s,a3,a4)
if(r===s)return a2
return A.hu(a1,r,!0)
case 7:s=a2.x
r=A.ay(a1,s,a3,a4)
if(r===s)return a2
return A.fy(a1,r,!0)
case 8:s=a2.x
r=A.ay(a1,s,a3,a4)
if(r===s)return a2
return A.hs(a1,r,!0)
case 9:q=a2.y
p=A.aZ(a1,q,a3,a4)
if(p===q)return a2
return A.bR(a1,a2.x,p)
case 10:o=a2.x
n=A.ay(a1,o,a3,a4)
m=a2.y
l=A.aZ(a1,m,a3,a4)
if(n===o&&l===m)return a2
return A.fw(a1,n,l)
case 11:k=a2.x
j=a2.y
i=A.aZ(a1,j,a3,a4)
if(i===j)return a2
return A.ht(a1,k,i)
case 12:h=a2.x
g=A.ay(a1,h,a3,a4)
f=a2.y
e=A.jZ(a1,f,a3,a4)
if(g===h&&e===f)return a2
return A.hr(a1,g,e)
case 13:d=a2.y
a4+=d.length
c=A.aZ(a1,d,a3,a4)
o=a2.x
n=A.ay(a1,o,a3,a4)
if(c===d&&n===o)return a2
return A.fx(a1,n,c,!0)
case 14:b=a2.x
if(b<a4)return a2
a=a3[b-a4]
if(a==null)return a2
return a
default:throw A.d(A.c2("Attempted to substitute unexpected RTI kind "+a0))}},
aZ(a,b,c,d){var s,r,q,p,o=b.length,n=A.eO(o)
for(s=!1,r=0;r<o;++r){q=b[r]
p=A.ay(a,q,c,d)
if(p!==q)s=!0
n[r]=p}return s?n:b},
k_(a,b,c,d){var s,r,q,p,o,n,m=b.length,l=A.eO(m)
for(s=!1,r=0;r<m;r+=3){q=b[r]
p=b[r+1]
o=b[r+2]
n=A.ay(a,o,c,d)
if(n!==o)s=!0
l.splice(r,3,q,p,n)}return s?l:b},
jZ(a,b,c,d){var s,r=b.a,q=A.aZ(a,r,c,d),p=b.b,o=A.aZ(a,p,c,d),n=b.c,m=A.k_(a,n,c,d)
if(q===r&&o===p&&m===n)return b
s=new A.cI()
s.a=q
s.b=o
s.c=m
return s},
a(a,b){a[v.arrayRti]=b
return a},
hN(a){var s=a.$S
if(s!=null){if(typeof s=="number")return A.ke(s)
return a.$S()}return null},
ki(a,b){var s
if(A.hb(b))if(a instanceof A.ap){s=A.hN(a)
if(s!=null)return s}return A.b0(a)},
b0(a){if(a instanceof A.b)return A.H(a)
if(Array.isArray(a))return A.P(a)
return A.fB(J.aJ(a))},
P(a){var s=a[v.arrayRti],r=t.b
if(s==null)return r
if(s.constructor!==r.constructor)return r
return s},
H(a){var s=a.$ti
return s!=null?s:A.fB(a)},
fB(a){var s=a.constructor,r=s.$ccache
if(r!=null)return r
return A.jF(a,s)},
jF(a,b){var s=a instanceof A.ap?Object.getPrototypeOf(Object.getPrototypeOf(a)).constructor:b,r=A.jm(v.typeUniverse,s.name)
b.$ccache=r
return r},
ke(a){var s,r=v.types,q=r[a]
if(typeof q=="string"){s=A.cN(v.typeUniverse,q,!1)
r[a]=s
return s}return q},
fG(a){return A.aH(A.H(a))},
fE(a){var s
if(a instanceof A.cJ)return A.ka(a.$r,a.dQ())
s=a instanceof A.ap?A.hN(a):null
if(s!=null)return s
if(t.bW.b(a))return J.id(a).a
if(Array.isArray(a))return A.P(a)
return A.b0(a)},
aH(a){var s=a.r
return s==null?a.r=A.hy(a):s},
hy(a){var s,r,q=a.as,p=q.replace(/\*/g,"")
if(p===q)return a.r=new A.eN(a)
s=A.cN(v.typeUniverse,p,!0)
r=s.r
return r==null?s.r=A.hy(s):r},
ka(a,b){var s,r,q=b,p=q.length
if(p===0)return t.cD
if(0>=p)return A.J(q,0)
s=A.bT(v.typeUniverse,A.fE(q[0]),"@<0>")
for(r=1;r<p;++r){if(!(r<q.length))return A.J(q,r)
s=A.hv(v.typeUniverse,s,A.fE(q[r]))}return A.bT(v.typeUniverse,s,a)},
a0(a){return A.aH(A.cN(v.typeUniverse,a,!1))},
jE(a){var s,r,q,p,o,n,m=this
if(m===t.K)return A.al(m,a,A.jN)
if(!A.am(m))s=m===t._
else s=!0
if(s)return A.al(m,a,A.jR)
s=m.w
if(s===7)return A.al(m,a,A.jC)
if(s===1)return A.al(m,a,A.hD)
r=s===6?m.x:m
q=r.w
if(q===8)return A.al(m,a,A.jJ)
if(r===t.S)p=A.hC
else if(r===t.i||r===t.q)p=A.jM
else if(r===t.N)p=A.jP
else p=r===t.y?A.eR:null
if(p!=null)return A.al(m,a,p)
if(q===9){o=r.x
if(r.y.every(A.kj)){m.f="$i"+o
if(o==="m")return A.al(m,a,A.jL)
return A.al(m,a,A.jQ)}}else if(q===11){n=A.k9(r.x,r.y)
return A.al(m,a,n==null?A.hD:n)}return A.al(m,a,A.jA)},
al(a,b,c){a.b=c
return a.b(b)},
jD(a){var s,r=this,q=A.jz
if(!A.am(r))s=r===t._
else s=!0
if(s)q=A.jr
else if(r===t.K)q=A.jq
else{s=A.c_(r)
if(s)q=A.jB}r.a=q
return r.a(a)},
cQ(a){var s=a.w,r=!0
if(!A.am(a))if(!(a===t._))if(!(a===t.L))if(s!==7)if(!(s===6&&A.cQ(a.x)))r=s===8&&A.cQ(a.x)||a===t.P||a===t.T
return r},
jA(a){var s=this
if(a==null)return A.cQ(s)
return A.hR(v.typeUniverse,A.ki(a,s),s)},
jC(a){if(a==null)return!0
return this.x.b(a)},
jQ(a){var s,r=this
if(a==null)return A.cQ(r)
s=r.f
if(a instanceof A.b)return!!a[s]
return!!J.aJ(a)[s]},
jL(a){var s,r=this
if(a==null)return A.cQ(r)
if(typeof a!="object")return!1
if(Array.isArray(a))return!0
s=r.f
if(a instanceof A.b)return!!a[s]
return!!J.aJ(a)[s]},
jz(a){var s=this
if(a==null){if(A.c_(s))return a}else if(s.b(a))return a
A.hz(a,s)},
jB(a){var s=this
if(a==null)return a
else if(s.b(a))return a
A.hz(a,s)},
hz(a,b){throw A.d(A.hq(A.hk(a,A.I(b,null))))},
k6(a,b,c,d){if(A.hR(v.typeUniverse,a,b))return a
throw A.d(A.hq("The type argument '"+A.I(a,null)+"' is not a subtype of the type variable bound '"+A.I(b,null)+"' of type variable '"+c+"' in '"+d+"'."))},
hk(a,b){return A.cb(a)+": type '"+A.I(A.fE(a),null)+"' is not a subtype of type '"+b+"'"},
hq(a){return new A.bP("TypeError: "+a)},
N(a,b){return new A.bP("TypeError: "+A.hk(a,b))},
jJ(a){var s=this,r=s.w===6?s.x:s
return r.x.b(a)||A.fm(v.typeUniverse,r).b(a)},
jN(a){return a!=null},
jq(a){if(a!=null)return a
throw A.d(A.N(a,"Object"))},
jR(a){return!0},
jr(a){return a},
hD(a){return!1},
eR(a){return!0===a||!1===a},
jo(a){if(!0===a)return!0
if(!1===a)return!1
throw A.d(A.N(a,"bool"))},
kL(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.d(A.N(a,"bool"))},
ax(a){if(!0===a)return!0
if(!1===a)return!1
if(a==null)return a
throw A.d(A.N(a,"bool?"))},
kM(a){if(typeof a=="number")return a
throw A.d(A.N(a,"double"))},
kO(a){if(typeof a=="number")return a
if(a==null)return a
throw A.d(A.N(a,"double"))},
kN(a){if(typeof a=="number")return a
if(a==null)return a
throw A.d(A.N(a,"double?"))},
hC(a){return typeof a=="number"&&Math.floor(a)===a},
a3(a){if(typeof a=="number"&&Math.floor(a)===a)return a
throw A.d(A.N(a,"int"))},
kQ(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.d(A.N(a,"int"))},
kP(a){if(typeof a=="number"&&Math.floor(a)===a)return a
if(a==null)return a
throw A.d(A.N(a,"int?"))},
jM(a){return typeof a=="number"},
kR(a){if(typeof a=="number")return a
throw A.d(A.N(a,"num"))},
kS(a){if(typeof a=="number")return a
if(a==null)return a
throw A.d(A.N(a,"num"))},
jp(a){if(typeof a=="number")return a
if(a==null)return a
throw A.d(A.N(a,"num?"))},
jP(a){return typeof a=="string"},
h(a){if(typeof a=="string")return a
throw A.d(A.N(a,"String"))},
kT(a){if(typeof a=="string")return a
if(a==null)return a
throw A.d(A.N(a,"String"))},
ak(a){if(typeof a=="string")return a
if(a==null)return a
throw A.d(A.N(a,"String?"))},
hI(a,b){var s,r,q
for(s="",r="",q=0;q<a.length;++q,r=", ")s+=r+A.I(a[q],b)
return s},
jU(a,b){var s,r,q,p,o,n,m=a.x,l=a.y
if(""===m)return"("+A.hI(l,b)+")"
s=l.length
r=m.split(",")
q=r.length-s
for(p="(",o="",n=0;n<s;++n,o=", "){p+=o
if(q===0)p+="{"
p+=A.I(l[n],b)
if(q>=0)p+=" "+r[q];++q}return p+"})"},
hA(a4,a5,a6){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=", ",a3=null
if(a6!=null){s=a6.length
if(a5==null)a5=A.a([],t.s)
else a3=a5.length
r=a5.length
for(q=s;q>0;--q)B.a.q(a5,"T"+(r+q))
for(p=t.X,o=t._,n="<",m="",q=0;q<s;++q,m=a2){l=a5.length
k=l-1-q
if(!(k>=0))return A.J(a5,k)
n=n+m+a5[k]
j=a6[q]
i=j.w
if(!(i===2||i===3||i===4||i===5||j===p))l=j===o
else l=!0
if(!l)n+=" extends "+A.I(j,a5)}n+=">"}else n=""
p=a4.x
h=a4.y
g=h.a
f=g.length
e=h.b
d=e.length
c=h.c
b=c.length
a=A.I(p,a5)
for(a0="",a1="",q=0;q<f;++q,a1=a2)a0+=a1+A.I(g[q],a5)
if(d>0){a0+=a1+"["
for(a1="",q=0;q<d;++q,a1=a2)a0+=a1+A.I(e[q],a5)
a0+="]"}if(b>0){a0+=a1+"{"
for(a1="",q=0;q<b;q+=3,a1=a2){a0+=a1
if(c[q+1])a0+="required "
a0+=A.I(c[q+2],a5)+" "+c[q]}a0+="}"}if(a3!=null){a5.toString
a5.length=a3}return n+"("+a0+") => "+a},
I(a,b){var s,r,q,p,o,n,m,l=a.w
if(l===5)return"erased"
if(l===2)return"dynamic"
if(l===3)return"void"
if(l===1)return"Never"
if(l===4)return"any"
if(l===6)return A.I(a.x,b)
if(l===7){s=a.x
r=A.I(s,b)
q=s.w
return(q===12||q===13?"("+r+")":r)+"?"}if(l===8)return"FutureOr<"+A.I(a.x,b)+">"
if(l===9){p=A.k0(a.x)
o=a.y
return o.length>0?p+("<"+A.hI(o,b)+">"):p}if(l===11)return A.jU(a,b)
if(l===12)return A.hA(a,b,null)
if(l===13)return A.hA(a.x,b,a.y)
if(l===14){n=a.x
m=b.length
n=m-1-n
if(!(n>=0&&n<m))return A.J(b,n)
return b[n]}return"?"},
k0(a){var s=v.mangledGlobalNames[a]
if(s!=null)return s
return"minified:"+a},
jn(a,b){var s=a.tR[b]
for(;typeof s=="string";)s=a.tR[s]
return s},
jm(a,b){var s,r,q,p,o,n=a.eT,m=n[b]
if(m==null)return A.cN(a,b,!1)
else if(typeof m=="number"){s=m
r=A.bS(a,5,"#")
q=A.eO(s)
for(p=0;p<s;++p)q[p]=r
o=A.bR(a,b,q)
n[b]=o
return o}else return m},
jl(a,b){return A.hw(a.tR,b)},
jk(a,b){return A.hw(a.eT,b)},
cN(a,b,c){var s,r=a.eC,q=r.get(b)
if(q!=null)return q
s=A.ho(A.hm(a,null,b,c))
r.set(b,s)
return s},
bT(a,b,c){var s,r,q=b.z
if(q==null)q=b.z=new Map()
s=q.get(c)
if(s!=null)return s
r=A.ho(A.hm(a,b,c,!0))
q.set(c,r)
return r},
hv(a,b,c){var s,r,q,p=b.Q
if(p==null)p=b.Q=new Map()
s=c.as
r=p.get(s)
if(r!=null)return r
q=A.fw(a,b,c.w===10?c.y:[c])
p.set(s,q)
return q},
aj(a,b){b.a=A.jD
b.b=A.jE
return b},
bS(a,b,c){var s,r,q=a.eC.get(c)
if(q!=null)return q
s=new A.V(null,null)
s.w=b
s.as=c
r=A.aj(a,s)
a.eC.set(c,r)
return r},
hu(a,b,c){var s,r=b.as+"*",q=a.eC.get(r)
if(q!=null)return q
s=A.ji(a,b,r,c)
a.eC.set(r,s)
return s},
ji(a,b,c,d){var s,r,q
if(d){s=b.w
if(!A.am(b))r=b===t.P||b===t.T||s===7||s===6
else r=!0
if(r)return b}q=new A.V(null,null)
q.w=6
q.x=b
q.as=c
return A.aj(a,q)},
fy(a,b,c){var s,r=b.as+"?",q=a.eC.get(r)
if(q!=null)return q
s=A.jh(a,b,r,c)
a.eC.set(r,s)
return s},
jh(a,b,c,d){var s,r,q,p
if(d){s=b.w
r=!0
if(!A.am(b))if(!(b===t.P||b===t.T))if(s!==7)r=s===8&&A.c_(b.x)
if(r)return b
else if(s===1||b===t.L)return t.P
else if(s===6){q=b.x
if(q.w===8&&A.c_(q.x))return q
else return A.ha(a,b)}}p=new A.V(null,null)
p.w=7
p.x=b
p.as=c
return A.aj(a,p)},
hs(a,b,c){var s,r=b.as+"/",q=a.eC.get(r)
if(q!=null)return q
s=A.jf(a,b,r,c)
a.eC.set(r,s)
return s},
jf(a,b,c,d){var s,r
if(d){s=b.w
if(A.am(b)||b===t.K||b===t._)return b
else if(s===1)return A.bR(a,"F",[b])
else if(b===t.P||b===t.T)return t.bc}r=new A.V(null,null)
r.w=8
r.x=b
r.as=c
return A.aj(a,r)},
jj(a,b){var s,r,q=""+b+"^",p=a.eC.get(q)
if(p!=null)return p
s=new A.V(null,null)
s.w=14
s.x=b
s.as=q
r=A.aj(a,s)
a.eC.set(q,r)
return r},
bQ(a){var s,r,q,p=a.length
for(s="",r="",q=0;q<p;++q,r=",")s+=r+a[q].as
return s},
je(a){var s,r,q,p,o,n=a.length
for(s="",r="",q=0;q<n;q+=3,r=","){p=a[q]
o=a[q+1]?"!":":"
s+=r+p+o+a[q+2].as}return s},
bR(a,b,c){var s,r,q,p=b
if(c.length>0)p+="<"+A.bQ(c)+">"
s=a.eC.get(p)
if(s!=null)return s
r=new A.V(null,null)
r.w=9
r.x=b
r.y=c
if(c.length>0)r.c=c[0]
r.as=p
q=A.aj(a,r)
a.eC.set(p,q)
return q},
fw(a,b,c){var s,r,q,p,o,n
if(b.w===10){s=b.x
r=b.y.concat(c)}else{r=c
s=b}q=s.as+(";<"+A.bQ(r)+">")
p=a.eC.get(q)
if(p!=null)return p
o=new A.V(null,null)
o.w=10
o.x=s
o.y=r
o.as=q
n=A.aj(a,o)
a.eC.set(q,n)
return n},
ht(a,b,c){var s,r,q="+"+(b+"("+A.bQ(c)+")"),p=a.eC.get(q)
if(p!=null)return p
s=new A.V(null,null)
s.w=11
s.x=b
s.y=c
s.as=q
r=A.aj(a,s)
a.eC.set(q,r)
return r},
hr(a,b,c){var s,r,q,p,o,n=b.as,m=c.a,l=m.length,k=c.b,j=k.length,i=c.c,h=i.length,g="("+A.bQ(m)
if(j>0){s=l>0?",":""
g+=s+"["+A.bQ(k)+"]"}if(h>0){s=l>0?",":""
g+=s+"{"+A.je(i)+"}"}r=n+(g+")")
q=a.eC.get(r)
if(q!=null)return q
p=new A.V(null,null)
p.w=12
p.x=b
p.y=c
p.as=r
o=A.aj(a,p)
a.eC.set(r,o)
return o},
fx(a,b,c,d){var s,r=b.as+("<"+A.bQ(c)+">"),q=a.eC.get(r)
if(q!=null)return q
s=A.jg(a,b,c,r,d)
a.eC.set(r,s)
return s},
jg(a,b,c,d,e){var s,r,q,p,o,n,m,l
if(e){s=c.length
r=A.eO(s)
for(q=0,p=0;p<s;++p){o=c[p]
if(o.w===1){r[p]=o;++q}}if(q>0){n=A.ay(a,b,r,0)
m=A.aZ(a,c,r,0)
return A.fx(a,n,m,c!==m)}}l=new A.V(null,null)
l.w=13
l.x=b
l.y=c
l.as=d
return A.aj(a,l)},
hm(a,b,c,d){return{u:a,e:b,r:c,s:[],p:0,n:d}},
ho(a){var s,r,q,p,o,n,m,l=a.r,k=a.s
for(s=l.length,r=0;r<s;){q=l.charCodeAt(r)
if(q>=48&&q<=57)r=A.j8(r+1,q,l,k)
else if((((q|32)>>>0)-97&65535)<26||q===95||q===36||q===124)r=A.hn(a,r,l,k,!1)
else if(q===46)r=A.hn(a,r,l,k,!0)
else{++r
switch(q){case 44:break
case 58:k.push(!1)
break
case 33:k.push(!0)
break
case 59:k.push(A.aw(a.u,a.e,k.pop()))
break
case 94:k.push(A.jj(a.u,k.pop()))
break
case 35:k.push(A.bS(a.u,5,"#"))
break
case 64:k.push(A.bS(a.u,2,"@"))
break
case 126:k.push(A.bS(a.u,3,"~"))
break
case 60:k.push(a.p)
a.p=k.length
break
case 62:A.ja(a,k)
break
case 38:A.j9(a,k)
break
case 42:p=a.u
k.push(A.hu(p,A.aw(p,a.e,k.pop()),a.n))
break
case 63:p=a.u
k.push(A.fy(p,A.aw(p,a.e,k.pop()),a.n))
break
case 47:p=a.u
k.push(A.hs(p,A.aw(p,a.e,k.pop()),a.n))
break
case 40:k.push(-3)
k.push(a.p)
a.p=k.length
break
case 41:A.j7(a,k)
break
case 91:k.push(a.p)
a.p=k.length
break
case 93:o=k.splice(a.p)
A.hp(a.u,a.e,o)
a.p=k.pop()
k.push(o)
k.push(-1)
break
case 123:k.push(a.p)
a.p=k.length
break
case 125:o=k.splice(a.p)
A.jc(a.u,a.e,o)
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
return A.aw(a.u,a.e,m)},
j8(a,b,c,d){var s,r,q=b-48
for(s=c.length;a<s;++a){r=c.charCodeAt(a)
if(!(r>=48&&r<=57))break
q=q*10+(r-48)}d.push(q)
return a},
hn(a,b,c,d,e){var s,r,q,p,o,n,m=b+1
for(s=c.length;m<s;++m){r=c.charCodeAt(m)
if(r===46){if(e)break
e=!0}else{if(!((((r|32)>>>0)-97&65535)<26||r===95||r===36||r===124))q=r>=48&&r<=57
else q=!0
if(!q)break}}p=c.substring(b,m)
if(e){s=a.u
o=a.e
if(o.w===10)o=o.x
n=A.jn(s,o.x)[p]
if(n==null)A.an('No "'+p+'" in "'+A.j1(o)+'"')
d.push(A.bT(s,o,n))}else d.push(p)
return m},
ja(a,b){var s,r=a.u,q=A.hl(a,b),p=b.pop()
if(typeof p=="string")b.push(A.bR(r,p,q))
else{s=A.aw(r,a.e,p)
switch(s.w){case 12:b.push(A.fx(r,s,q,a.n))
break
default:b.push(A.fw(r,s,q))
break}}},
j7(a,b){var s,r,q,p=a.u,o=b.pop(),n=null,m=null
if(typeof o=="number")switch(o){case-1:n=b.pop()
break
case-2:m=b.pop()
break
default:b.push(o)
break}else b.push(o)
s=A.hl(a,b)
o=b.pop()
switch(o){case-3:o=b.pop()
if(n==null)n=p.sEA
if(m==null)m=p.sEA
r=A.aw(p,a.e,o)
q=new A.cI()
q.a=s
q.b=n
q.c=m
b.push(A.hr(p,r,q))
return
case-4:b.push(A.ht(p,b.pop(),s))
return
default:throw A.d(A.c2("Unexpected state under `()`: "+A.w(o)))}},
j9(a,b){var s=b.pop()
if(0===s){b.push(A.bS(a.u,1,"0&"))
return}if(1===s){b.push(A.bS(a.u,4,"1&"))
return}throw A.d(A.c2("Unexpected extended operation "+A.w(s)))},
hl(a,b){var s=b.splice(a.p)
A.hp(a.u,a.e,s)
a.p=b.pop()
return s},
aw(a,b,c){if(typeof c=="string")return A.bR(a,c,a.sEA)
else if(typeof c=="number"){b.toString
return A.jb(a,b,c)}else return c},
hp(a,b,c){var s,r=c.length
for(s=0;s<r;++s)c[s]=A.aw(a,b,c[s])},
jc(a,b,c){var s,r=c.length
for(s=2;s<r;s+=3)c[s]=A.aw(a,b,c[s])},
jb(a,b,c){var s,r,q=b.w
if(q===10){if(c===0)return b.x
s=b.y
r=s.length
if(c<=r)return s[c-1]
c-=r
b=b.x
q=b.w}else if(c===0)return b
if(q!==9)throw A.d(A.c2("Indexed base must be an interface type"))
s=b.y
if(c<=s.length)return s[c-1]
throw A.d(A.c2("Bad index "+c+" for "+b.i(0)))},
hR(a,b,c){var s,r=b.d
if(r==null)r=b.d=new Map()
s=r.get(c)
if(s==null){s=A.A(a,b,null,c,null,!1)?1:0
r.set(c,s)}if(0===s)return!1
if(1===s)return!0
return!0},
A(a,b,c,d,e,f){var s,r,q,p,o,n,m,l,k,j,i
if(b===d)return!0
if(!A.am(d))s=d===t._
else s=!0
if(s)return!0
r=b.w
if(r===4)return!0
if(A.am(b))return!1
s=b.w
if(s===1)return!0
q=r===14
if(q)if(A.A(a,c[b.x],c,d,e,!1))return!0
p=d.w
s=b===t.P||b===t.T
if(s){if(p===8)return A.A(a,b,c,d.x,e,!1)
return d===t.P||d===t.T||p===7||p===6}if(d===t.K){if(r===8)return A.A(a,b.x,c,d,e,!1)
if(r===6)return A.A(a,b.x,c,d,e,!1)
return r!==7}if(r===6)return A.A(a,b.x,c,d,e,!1)
if(p===6){s=A.ha(a,d)
return A.A(a,b,c,s,e,!1)}if(r===8){if(!A.A(a,b.x,c,d,e,!1))return!1
return A.A(a,A.fm(a,b),c,d,e,!1)}if(r===7){s=A.A(a,t.P,c,d,e,!1)
return s&&A.A(a,b.x,c,d,e,!1)}if(p===8){if(A.A(a,b,c,d.x,e,!1))return!0
return A.A(a,b,c,A.fm(a,d),e,!1)}if(p===7){s=A.A(a,b,c,t.P,e,!1)
return s||A.A(a,b,c,d.x,e,!1)}if(q)return!1
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
if(!A.A(a,j,c,i,e,!1)||!A.A(a,i,e,j,c,!1))return!1}return A.hB(a,b.x,c,d.x,e,!1)}if(p===12){if(b===t.g)return!0
if(s)return!1
return A.hB(a,b,c,d,e,!1)}if(r===9){if(p!==9)return!1
return A.jK(a,b,c,d,e,!1)}if(o&&p===11)return A.jO(a,b,c,d,e,!1)
return!1},
hB(a3,a4,a5,a6,a7,a8){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2
if(!A.A(a3,a4.x,a5,a6.x,a7,!1))return!1
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
if(!A.A(a3,p[h],a7,g,a5,!1))return!1}for(h=0;h<m;++h){g=l[h]
if(!A.A(a3,p[o+h],a7,g,a5,!1))return!1}for(h=0;h<i;++h){g=l[m+h]
if(!A.A(a3,k[h],a7,g,a5,!1))return!1}f=s.c
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
if(!A.A(a3,e[a+2],a7,g,a5,!1))return!1
break}}for(;b<d;){if(f[b+1])return!1
b+=3}return!0},
jK(a,b,c,d,e,f){var s,r,q,p,o,n=b.x,m=d.x
for(;n!==m;){s=a.tR[n]
if(s==null)return!1
if(typeof s=="string"){n=s
continue}r=s[m]
if(r==null)return!1
q=r.length
p=q>0?new Array(q):v.typeUniverse.sEA
for(o=0;o<q;++o)p[o]=A.bT(a,b,r[o])
return A.hx(a,p,null,c,d.y,e,!1)}return A.hx(a,b.y,null,c,d.y,e,!1)},
hx(a,b,c,d,e,f,g){var s,r=b.length
for(s=0;s<r;++s)if(!A.A(a,b[s],d,e[s],f,!1))return!1
return!0},
jO(a,b,c,d,e,f){var s,r=b.y,q=d.y,p=r.length
if(p!==q.length)return!1
if(b.x!==d.x)return!1
for(s=0;s<p;++s)if(!A.A(a,r[s],c,q[s],e,!1))return!1
return!0},
c_(a){var s=a.w,r=!0
if(!(a===t.P||a===t.T))if(!A.am(a))if(s!==7)if(!(s===6&&A.c_(a.x)))r=s===8&&A.c_(a.x)
return r},
kj(a){var s
if(!A.am(a))s=a===t._
else s=!0
return s},
am(a){var s=a.w
return s===2||s===3||s===4||s===5||a===t.X},
hw(a,b){var s,r,q=Object.keys(b),p=q.length
for(s=0;s<p;++s){r=q[s]
a[r]=b[r]}},
eO(a){return a>0?new Array(a):v.typeUniverse.sEA},
V:function V(a,b){var _=this
_.a=a
_.b=b
_.r=_.f=_.d=_.c=null
_.w=0
_.as=_.Q=_.z=_.y=_.x=null},
cI:function cI(){this.c=this.b=this.a=null},
eN:function eN(a){this.a=a},
cH:function cH(){},
bP:function bP(a){this.a=a},
j3(){var s,r,q
if(self.scheduleImmediate!=null)return A.k3()
if(self.MutationObserver!=null&&self.document!=null){s={}
r=self.document.createElement("div")
q=self.document.createElement("span")
s.a=null
new self.MutationObserver(A.bY(new A.em(s),1)).observe(r,{childList:true})
return new A.el(s,r,q)}else if(self.setImmediate!=null)return A.k4()
return A.k5()},
j4(a){self.scheduleImmediate(A.bY(new A.en(t.M.a(a)),0))},
j5(a){self.setImmediate(A.bY(new A.eo(t.M.a(a)),0))},
j6(a){A.fp(B.I,t.M.a(a))},
fp(a,b){return A.jd(0,b)},
jd(a,b){var s=new A.eL()
s.bO(a,b)
return s},
Z(a){return new A.bE(new A.n($.o,a.h("n<0>")),a.h("bE<0>"))},
Y(a,b){a.$2(0,null)
b.b=!0
return b.a},
a4(a,b){A.js(a,b)},
X(a,b){b.V(a)},
W(a,b){b.aS(A.ao(a),A.az(a))},
js(a,b){var s,r,q=new A.eP(b),p=new A.eQ(b)
if(a instanceof A.n)a.bq(q,p,t.z)
else{s=t.z
if(a instanceof A.n)a.Y(q,p,s)
else{r=new A.n($.o,t.d)
r.a=8
r.c=a
r.bq(q,p,s)}}},
a_(a){var s=function(b,c){return function(d,e){while(true){try{b(d,e)
break}catch(r){e=r
d=c}}}}(a,1)
return $.o.by(new A.eT(s),t.H,t.S,t.z)},
fd(a){var s
if(t.C.b(a)){s=a.ga2()
if(s!=null)return s}return B.o},
it(a,b){var s,r=!b.b(null)
if(r)throw A.d(A.fc(null,"computation","The type parameter is not nullable"))
s=new A.n($.o,b.h("n<0>"))
A.he(a,new A.d8(null,s,b))
return s},
jG(a,b){if($.o===B.e)return null
return null},
jH(a,b){if($.o!==B.e)A.jG(a,b)
if(b==null)if(t.C.b(a)){b=a.ga2()
if(b==null){A.h8(a,B.o)
b=B.o}}else b=B.o
else if(t.C.b(a))A.h8(a,b)
return new A.a8(a,b)},
fr(a,b){var s=new A.n($.o,b.h("n<0>"))
b.a(a)
s.a=8
s.c=a
return s},
eu(a,b,c){var s,r,q,p,o={},n=o.a=a
for(s=t.d;r=n.a,(r&4)!==0;n=a){a=s.a(n.c)
o.a=a}if(n===b){b.aG(new A.a6(!0,n,null,"Cannot complete a future with itself"),A.hc())
return}q=b.a&1
s=n.a=r|q
if((s&24)===0){p=t.F.a(b.c)
b.a=b.a&1|4
b.c=n
n.bk(p)
return}if(!c)if(b.c==null)n=(s&16)===0||q!==0
else n=!1
else n=!0
if(n){p=b.aa()
b.aj(o.a)
A.aF(b,p)
return}b.a^=2
A.aY(null,null,b.b,t.M.a(new A.ev(o,b)))},
aF(a,a0){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c={},b=c.a=a
for(s=t.n,r=t.F,q=t.t;!0;){p={}
o=b.a
n=(o&16)===0
m=!n
if(a0==null){if(m&&(o&1)===0){l=s.a(b.c)
A.fD(l.a,l.b)}return}p.a=a0
k=a0.a
for(b=a0;k!=null;b=k,k=j){b.a=null
A.aF(c.a,b)
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
A.fD(i.a,i.b)
return}f=$.o
if(f!==g)$.o=g
else f=null
b=b.c
if((b&15)===8)new A.eC(p,c,m).$0()
else if(n){if((b&1)!==0)new A.eB(p,i).$0()}else if((b&2)!==0)new A.eA(c,p).$0()
if(f!=null)$.o=f
b=p.c
if(b instanceof A.n){o=p.a.$ti
o=o.h("F<2>").b(b)||!o.y[1].b(b)}else o=!1
if(o){q.a(b)
e=p.a.b
if((b.a&24)!==0){d=r.a(e.c)
e.c=null
a0=e.ap(d)
e.a=b.a&30|e.a&1
e.c=b.c
c.a=b
continue}else A.eu(b,e,!0)
return}}e=p.a.b
d=r.a(e.c)
e.c=null
a0=e.ap(d)
b=p.b
o=p.c
if(!b){e.$ti.c.a(o)
e.a=8
e.c=o}else{s.a(o)
e.a=e.a&1|16
e.c=o}c.a=e
b=e}},
hG(a,b){var s
if(t.Q.b(a))return b.by(a,t.z,t.K,t.l)
s=t.v
if(s.b(a))return s.a(a)
throw A.d(A.fc(a,"onError",u.c))},
jT(){var s,r
for(s=$.aX;s!=null;s=$.aX){$.bX=null
r=s.b
$.aX=r
if(r==null)$.bW=null
s.a.$0()}},
jY(){$.fC=!0
try{A.jT()}finally{$.bX=null
$.fC=!1
if($.aX!=null)$.fM().$1(A.hL())}},
hJ(a){var s=new A.cF(a),r=$.bW
if(r==null){$.aX=$.bW=s
if(!$.fC)$.fM().$1(A.hL())}else $.bW=r.b=s},
jX(a){var s,r,q,p=$.aX
if(p==null){A.hJ(a)
$.bX=$.bW
return}s=new A.cF(a)
r=$.bX
if(r==null){s.b=p
$.aX=$.bX=s}else{q=r.b
s.b=q
$.bX=r.b=s
if(q==null)$.bW=s}},
kp(a){var s=null,r=$.o
if(B.e===r){A.aY(s,s,B.e,a)
return}A.aY(s,s,r,t.M.a(r.aP(a)))},
kx(a,b){A.eV(a,"stream",t.K)
return new A.cL(b.h("cL<0>"))},
he(a,b){var s=$.o
if(s===B.e)return A.fp(a,t.M.a(b))
return A.fp(a,t.M.a(s.aP(b)))},
fD(a,b){A.jX(new A.eS(a,b))},
hH(a,b,c,d,e){var s,r=$.o
if(r===c)return d.$0()
$.o=c
s=r
try{r=d.$0()
return r}finally{$.o=s}},
jW(a,b,c,d,e,f,g){var s,r=$.o
if(r===c)return d.$1(e)
$.o=c
s=r
try{r=d.$1(e)
return r}finally{$.o=s}},
jV(a,b,c,d,e,f,g,h,i){var s,r=$.o
if(r===c)return d.$2(e,f)
$.o=c
s=r
try{r=d.$2(e,f)
return r}finally{$.o=s}},
aY(a,b,c,d){t.M.a(d)
if(B.e!==c)d=c.aP(d)
A.hJ(d)},
em:function em(a){this.a=a},
el:function el(a,b,c){this.a=a
this.b=b
this.c=c},
en:function en(a){this.a=a},
eo:function eo(a){this.a=a},
eL:function eL(){this.b=null},
eM:function eM(a,b){this.a=a
this.b=b},
bE:function bE(a,b){this.a=a
this.b=!1
this.$ti=b},
eP:function eP(a){this.a=a},
eQ:function eQ(a){this.a=a},
eT:function eT(a){this.a=a},
a8:function a8(a,b){this.a=a
this.b=b},
d8:function d8(a,b,c){this.a=a
this.b=b
this.c=c},
e3:function e3(a,b){this.a=a
this.b=b},
aV:function aV(){},
ah:function ah(a,b){this.a=a
this.$ti=b},
bO:function bO(a,b){this.a=a
this.$ti=b},
ai:function ai(a,b,c,d,e){var _=this
_.a=null
_.b=a
_.c=b
_.d=c
_.e=d
_.$ti=e},
n:function n(a,b){var _=this
_.a=0
_.b=a
_.c=null
_.$ti=b},
er:function er(a,b){this.a=a
this.b=b},
ez:function ez(a,b){this.a=a
this.b=b},
ew:function ew(a){this.a=a},
ex:function ex(a){this.a=a},
ey:function ey(a,b,c){this.a=a
this.b=b
this.c=c},
ev:function ev(a,b){this.a=a
this.b=b},
et:function et(a,b){this.a=a
this.b=b},
es:function es(a,b,c){this.a=a
this.b=b
this.c=c},
eC:function eC(a,b,c){this.a=a
this.b=b
this.c=c},
eD:function eD(a,b){this.a=a
this.b=b},
eE:function eE(a){this.a=a},
eB:function eB(a,b){this.a=a
this.b=b},
eA:function eA(a,b){this.a=a
this.b=b},
eF:function eF(a,b){this.a=a
this.b=b},
eG:function eG(a,b,c){this.a=a
this.b=b
this.c=c},
eH:function eH(a,b){this.a=a
this.b=b},
cF:function cF(a){this.a=a
this.b=null},
cL:function cL(a){this.$ti=a},
bU:function bU(){},
eS:function eS(a,b){this.a=a
this.b=b},
cK:function cK(){},
eK:function eK(a,b){this.a=a
this.b=b},
fs(a,b){var s=a[b]
return s===a?null:s},
fu(a,b,c){if(c==null)a[b]=a
else a[b]=c},
ft(){var s=Object.create(null)
A.fu(s,"<non-identifier-key>",s)
delete s["<non-identifier-key>"]
return s},
iG(a,b){return new A.aa(a.h("@<0>").n(b).h("aa<1,2>"))},
C(a,b,c){return b.h("@<0>").n(c).h("h2<1,2>").a(A.kb(a,new A.aa(b.h("@<0>").n(c).h("aa<1,2>"))))},
fk(a,b){return new A.aa(a.h("@<0>").n(b).h("aa<1,2>"))},
h3(a,b,c){var s=A.iG(b,c)
a.ad(0,new A.dL(s,b,c))
return s},
fl(a){var s,r
if(A.fI(a))return"{...}"
s=new A.cA("")
try{r={}
B.a.q($.S,a)
s.a+="{"
r.a=!0
a.ad(0,new A.dN(r,s))
s.a+="}"}finally{if(0>=$.S.length)return A.J($.S,-1)
$.S.pop()}r=s.a
return r.charCodeAt(0)==0?r:r},
bG:function bG(){},
aW:function aW(a){var _=this
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
dL:function dL(a,b,c){this.a=a
this.b=b
this.c=c},
p:function p(){},
ac:function ac(){},
dN:function dN(a,b){this.a=a
this.b=b},
iq(a,b){a=A.d(a)
if(a==null)a=t.K.a(a)
a.stack=b.i(0)
throw a
throw A.d("unreachable")},
h4(a,b,c,d){var s,r=c?J.fX(a,d):J.iA(a,d)
if(a!==0&&b!=null)for(s=0;s<r.length;++s)r[s]=b
return r},
iJ(a,b,c){var s,r=A.a([],c.h("l<0>"))
for(s=J.b3(a);s.l();)B.a.q(r,c.a(s.gm()))
if(b)return r
r.$flags=1
return r},
ab(a,b,c){var s=A.iI(a,c)
return s},
iI(a,b){var s,r
if(Array.isArray(a))return A.a(a.slice(0),b.h("l<0>"))
s=A.a([],b.h("l<0>"))
for(r=J.b3(a);r.l();)B.a.q(s,r.gm())
return s},
iK(a,b,c){var s,r=J.fX(a,c)
for(s=0;s<a;++s)B.a.C(r,s,b.$1(s))
return r},
hd(a,b,c){var s=J.b3(b)
if(!s.l())return a
if(c.length===0){do a+=A.w(s.gm())
while(s.l())}else{a+=A.w(s.gm())
for(;s.l();)a=a+c+A.w(s.gm())}return a},
hc(){return A.az(new Error())},
io(a){var s=Math.abs(a),r=a<0?"-":""
if(s>=1000)return""+a
if(s>=100)return r+"0"+s
if(s>=10)return r+"00"+s
return r+"000"+s},
fT(a){if(a>=100)return""+a
if(a>=10)return"0"+a
return"00"+a},
c9(a){if(a>=10)return""+a
return"0"+a},
cb(a){if(typeof a=="number"||A.eR(a)||a==null)return J.b4(a)
if(typeof a=="string")return JSON.stringify(a)
return A.iY(a)},
ir(a,b){A.eV(a,"error",t.K)
A.eV(b,"stackTrace",t.l)
A.iq(a,b)},
c2(a){return new A.b7(a)},
a7(a,b){return new A.a6(!1,null,b,a)},
fc(a,b,c){return new A.a6(!0,a,b,c)},
aE(a,b,c,d,e){return new A.aS(b,c,!0,a,d,"Invalid value")},
j0(a,b,c){if(0>a||a>c)throw A.d(A.aE(a,0,c,"start",null))
if(b!=null){if(a>b||b>c)throw A.d(A.aE(b,a,c,"end",null))
return b}return c},
j_(a,b){if(a<0)throw A.d(A.aE(a,0,null,b,null))
return a},
fV(a,b,c,d){return new A.cc(b,!0,a,d,"Index out of range")},
ef(a){return new A.bC(a)},
fq(a){return new A.cC(a)},
fn(a){return new A.aT(a)},
aq(a){return new A.c7(a)},
iv(a,b,c){var s,r
if(A.fI(a)){if(b==="("&&c===")")return"(...)"
return b+"..."+c}s=A.a([],t.s)
B.a.q($.S,a)
try{A.jS(a,s)}finally{if(0>=$.S.length)return A.J($.S,-1)
$.S.pop()}r=A.hd(b,t.R.a(s),", ")+c
return r.charCodeAt(0)==0?r:r},
fW(a,b,c){var s,r
if(A.fI(a))return b+"..."+c
s=new A.cA(b)
B.a.q($.S,a)
try{r=s
r.a=A.hd(r.a,a,", ")}finally{if(0>=$.S.length)return A.J($.S,-1)
$.S.pop()}s.a+=c
r=s.a
return r.charCodeAt(0)==0?r:r},
jS(a,b){var s,r,q,p,o,n,m,l=a.gB(a),k=0,j=0
while(!0){if(!(k<80||j<3))break
if(!l.l())return
s=A.w(l.gm())
B.a.q(b,s)
k+=s.length+2;++j}if(!l.l()){if(j<=5)return
if(0>=b.length)return A.J(b,-1)
r=b.pop()
if(0>=b.length)return A.J(b,-1)
q=b.pop()}else{p=l.gm();++j
if(!l.l()){if(j<=4){B.a.q(b,A.w(p))
return}r=A.w(p)
if(0>=b.length)return A.J(b,-1)
q=b.pop()
k+=r.length+2}else{o=l.gm();++j
for(;l.l();p=o,o=n){n=l.gm();++j
if(j>100){while(!0){if(!(k>75&&j>3))break
if(0>=b.length)return A.J(b,-1)
k-=b.pop().length+2;--j}B.a.q(b,"...")
return}}q=A.w(p)
r=A.w(o)
k+=r.length+q.length+4}}if(j>b.length+2){k+=5
m="..."}else m=null
while(!0){if(!(k>80&&b.length>3))break
if(0>=b.length)return A.J(b,-1)
k-=b.pop().length+2
if(m==null){k+=5
m="..."}}if(m!=null)B.a.q(b,m)
B.a.q(b,q)
B.a.q(b,r)},
iO(a,b,c,d){var s
if(B.n===c){s=B.f.gt(a)
b=J.a5(b)
return A.fo(A.av(A.av($.fa(),s),b))}if(B.n===d){s=B.f.gt(a)
b=J.a5(b)
c=J.a5(c)
return A.fo(A.av(A.av(A.av($.fa(),s),b),c))}s=B.f.gt(a)
b=J.a5(b)
c=J.a5(c)
d=J.a5(d)
d=A.fo(A.av(A.av(A.av(A.av($.fa(),s),b),c),d))
return d},
c8:function c8(a,b,c){this.a=a
this.b=b
this.c=c},
ca:function ca(){},
ep:function ep(){},
u:function u(){},
b7:function b7(a){this.a=a},
af:function af(){},
a6:function a6(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
aS:function aS(a,b,c,d,e,f){var _=this
_.e=a
_.f=b
_.a=c
_.b=d
_.c=e
_.d=f},
cc:function cc(a,b,c,d,e){var _=this
_.f=a
_.a=b
_.b=c
_.c=d
_.d=e},
bC:function bC(a){this.a=a},
cC:function cC(a){this.a=a},
aT:function aT(a){this.a=a},
c7:function c7(a){this.a=a},
cs:function cs(){},
bv:function bv(){},
eq:function eq(a){this.a=a},
i:function i(){},
ad:function ad(a,b,c){this.a=a
this.b=b
this.$ti=c},
B:function B(){},
b:function b(){},
cM:function cM(){},
cA:function cA(a){this.a=a},
iH(a,b){return a},
iw(a,b){var s,r,q,p,o,n
if(b.length===0)return!1
s=b.split(".")
r=t.m.a(self)
for(q=s.length,p=t.A,o=0;o<q;++o){n=s[o]
r=p.a(r[n])
if(r==null)return!1}return a instanceof t.g.a(r)},
is(a){return t.m.a(new self.Promise(A.v(new A.d7(a))))},
d7:function d7(a){this.a=a},
d5:function d5(a){this.a=a},
d6:function d6(a){this.a=a},
r(a){var s
if(typeof a=="function")throw A.d(A.a7("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(){return b(c)}}(A.jt,a)
s[$.b2()]=a
return s},
e(a){var s
if(typeof a=="function")throw A.d(A.a7("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d){return b(c,d,arguments.length)}}(A.ju,a)
s[$.b2()]=a
return s},
v(a){var s
if(typeof a=="function")throw A.d(A.a7("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e){return b(c,d,e,arguments.length)}}(A.jv,a)
s[$.b2()]=a
return s},
fz(a){var s
if(typeof a=="function")throw A.d(A.a7("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e,f){return b(c,d,e,f,arguments.length)}}(A.jw,a)
s[$.b2()]=a
return s},
fA(a){var s
if(typeof a=="function")throw A.d(A.a7("Attempting to rewrap a JS function.",null))
s=function(b,c){return function(d,e,f,g){return b(c,d,e,f,g,arguments.length)}}(A.jx,a)
s[$.b2()]=a
return s},
jt(a){return t.Z.a(a).$0()},
ju(a,b,c){t.Z.a(a)
if(A.a3(c)>=1)return a.$1(b)
return a.$0()},
jv(a,b,c,d){t.Z.a(a)
A.a3(d)
if(d>=2)return a.$2(b,c)
if(d===1)return a.$1(b)
return a.$0()},
jw(a,b,c,d,e){t.Z.a(a)
A.a3(e)
if(e>=3)return a.$3(b,c,d)
if(e===2)return a.$2(b,c)
if(e===1)return a.$1(b)
return a.$0()},
jx(a,b,c,d,e,f){t.Z.a(a)
A.a3(f)
if(f>=4)return a.$4(b,c,d,e)
if(f===3)return a.$3(b,c,d)
if(f===2)return a.$2(b,c)
if(f===1)return a.$1(b)
return a.$0()},
hF(a){return a==null||A.eR(a)||typeof a=="number"||typeof a=="string"||t.by.b(a)||t.bX.b(a)||t.ca.b(a)||t.w.b(a)||t.c0.b(a)||t.k.b(a)||t.bk.b(a)||t.E.b(a)||t.W.b(a)||t.B.b(a)||t.Y.b(a)},
f4(a){if(A.hF(a))return a
return new A.f5(new A.aW(t.J)).$1(a)},
eU(a,b,c){var s,r
if(b==null)return c.a(new a())
if(b instanceof Array)switch(b.length){case 0:return c.a(new a())
case 1:return c.a(new a(b[0]))
case 2:return c.a(new a(b[0],b[1]))
case 3:return c.a(new a(b[0],b[1],b[2]))
case 4:return c.a(new a(b[0],b[1],b[2],b[3]))}s=[null]
B.a.bt(s,b)
r=a.bind.apply(a,s)
String(r)
return c.a(new r())},
hT(a,b){var s=new A.n($.o,b.h("n<0>")),r=new A.ah(s,b.h("ah<0>"))
a.then(A.bY(new A.f8(r,b),1),A.bY(new A.f9(r),1))
return s},
hE(a){return a==null||typeof a==="boolean"||typeof a==="number"||typeof a==="string"||a instanceof Int8Array||a instanceof Uint8Array||a instanceof Uint8ClampedArray||a instanceof Int16Array||a instanceof Uint16Array||a instanceof Int32Array||a instanceof Uint32Array||a instanceof Float32Array||a instanceof Float64Array||a instanceof ArrayBuffer||a instanceof DataView},
eW(a){if(A.hE(a))return a
return new A.eX(new A.aW(t.J)).$1(a)},
f5:function f5(a){this.a=a},
f8:function f8(a,b){this.a=a
this.b=b},
f9:function f9(a){this.a=a},
eX:function eX(a){this.a=a},
dO:function dO(a){this.a=a},
eI:function eI(a){this.a=a},
j2(){var s,r,q,p=A.iK(16,new A.e9($.hY()),t.S)
B.a.C(p,6,p[6]&15|64)
B.a.C(p,8,p[8]&63|128)
s=A.P(p)
r=s.h("M<1,k>")
q=A.ab(new A.M(p,s.h("k(1)").a(new A.ea()),r),!0,r.h("G.E"))
return B.a.ae(B.a.a3(q,0,4),"")+"-"+B.a.ae(B.a.a3(q,4,6),"")+"-"+B.a.ae(B.a.a3(q,6,8),"")+"-"+B.a.ae(B.a.a3(q,8,10),"")+"-"+B.a.ae(B.a.bI(q,10),"")},
e9:function e9(a){this.a=a},
ea:function ea(){},
iL(a){var s=t.r.a(self.Object.keys(a))
if(s==null)s=null
else{s=t.a.b(s)?s:new A.a9(s,A.P(s).h("a9<1,k>"))
s=J.cU(s,new A.dM(),t.N)
s=A.ab(s,!0,s.$ti.h("G.E"))}return s},
dM:function dM(){},
d2:function d2(){},
e0:function e0(){this.a=null},
e2:function e2(a,b){this.a=a
this.b=b},
e1:function e1(a){this.a=a},
bD:function bD(a,b){this.a=a
this.b=b},
cP:function cP(){},
iz(a){var s,r,q,p
try{r=A.iL(a)
r=r==null?null:B.a.ds(r,"secondarySignerAddresses")
s=r===!0
q={}
q.data=t.K.a(a.bcsToBytes())
q.isMultiAgent=s
return q}catch(p){throw A.d(new A.bD("Invalid method parameters: Invalid Aptos transaction. The transaction must be a valid Aptos transaction and include a method like bcsToBytes.",-32602))}},
ix(a){return new A.dg(a)},
iy(a){return new A.df(a)},
ff(a){a.bcsToBytes=A.r(new A.dc(a))
a.serialize=A.e(new A.dd(a))
a.bcsToHex=A.r(new A.de(a))
a.toStringWithoutPrefix=A.r(A.iy(a))
a.toString=A.r(A.ix(a))},
fg(a){return B.a.W(B.a5,new A.dh(a),new A.di())},
fh(a,b){var s={}
s.status="Approved"
s.args=a
return s},
dg:function dg(a){this.a=a},
df:function df(a){this.a=a},
dc:function dc(a){this.a=a},
dd:function dd(a){this.a=a},
de:function de(a){this.a=a},
ar:function ar(a,b){this.c=a
this.b=b},
dh:function dh(a){this.a=a},
di:function di(){},
ct:function ct(a,b){this.a=a
this.b=b},
ip(a){var s=self,r=t.m,q=r.a(new s.CustomEvent("eip6963:announceProvider",{bubbles:!0,cancelable:!1,detail:t.K.a(s.Object.freeze({info:$.hX(),provider:a}))}))
r.a(s.window).addEventListener("eip6963:requestProvider",A.e(new A.d1(q)))
r.a(s.window).dispatchEvent(q)},
ae:function ae(a,b,c){this.a=a
this.b=b
this.$ti=c},
d1:function d1(a){this.a=a},
h0(a){var s,r=A.h3(a,t.N,t.z)
if(r.j(0,"stack")==null)r.C(0,"stack",null)
r.dE(0,new A.dA())
s=A.f4(r)
if(s==null)s={}
s.toString=A.r(new A.dB(a))
return s},
dA:function dA(){},
dB:function dB(a){this.a=a},
R(a,b){return t.m.a(new self.Promise(A.v(new A.ek(a))))},
O(a,b){return A.eU(self.Proxy,[a,new A.dU(new A.ae(null,a,b.h("ae<0>"))).$0()],t.m)},
h9(a){var s=A.P(a),r=s.h("M<1,k>")
return A.ab(new A.M(a,s.h("k(1)").a(new A.dR()),r),!0,r.h("G.E"))},
ek:function ek(a){this.a=a},
eh:function eh(a){this.a=a},
ei:function ei(a){this.a=a},
ej:function ej(a,b){this.a=a
this.b=b},
dS:function dS(a){this.a=a},
dT:function dT(a){this.a=a},
dU:function dU(a){this.a=a},
dR:function dR(){},
fJ(a){return A.km(a)},
km(a){var s=0,r=A.Z(t.H),q,p,o
var $async$fJ=A.a_(function(b,c){if(b===1)return A.W(c,r)
while(true)switch(s){case 0:p={}
o=new A.ch(new A.e0(),new A.ah(new A.n($.o,t.U),t.h))
o.ck()
q=self
q.MRT={}
p.a=!1
t.m.a(q.window).addEventListener("WALLET_ACTIVATION",A.e(new A.f6(p,o)))
return A.X(null,r)}})
return A.Y($async$fJ,r)},
f6:function f6(a,b){this.a=a
this.b=b},
iF(a){return B.a.W(B.a2,new A.dC(a),new A.dD())},
iD(a){return B.a.W(B.a4,new A.dr(a),new A.ds())},
iC(a){return B.a.W(B.O,new A.dp(a),new A.dq())},
be(a){return A.iZ(B.O,new A.dn(a),t.G)},
h1(a){return B.a.W(B.a6,new A.dH(a),new A.dI())},
fY(a){return B.a.W(B.a3,new A.dl(a),new A.dm())},
hh(a,b){b.ad(0,new A.eg(b,a))
return A.h3(b,t.N,t.z)},
hi(a){var s=a.data
s=s==null?null:A.eW(s)
return A.hh(a,t.bC.a(s))},
h5(a,b){var s=a==null?null:a.b
return{data:b,requestId:"event",client:s}},
aQ(a){return{type:"event",event:a.b,data:null,providerType:"walletStandard"}},
as:function as(a){this.b=a},
dC:function dC(a){this.a=a},
dD:function dD(){},
L:function L(a){this.b=a},
dr:function dr(a){this.a=a},
ds:function ds(){},
U:function U(a){this.b=a},
dp:function dp(a){this.a=a},
dq:function dq(){},
dn:function dn(a){this.a=a},
at:function at(a){this.b=a},
dH:function dH(a){this.a=a},
dI:function dI(){},
D:function D(a){this.b=a},
dl:function dl(a){this.a=a},
dm:function dm(){},
cv:function cv(a){this.b=a},
eg:function eg(a,b){this.a=a
this.b=b},
fv(a){var s
if(a!=null&&typeof a==="string"){s=A.h(a).length
if(s===64||s===66)throw A.d({message:"Please use static method `TronWeb.TRX.sign` for signing with own private key"})}},
dj:function dj(){},
dk:function dk(a){this.a=a},
ch:function ch(a,b){var _=this
_.b=_.a=$
_.c=a
_.d=b
_.e=$
_.f=null},
bh:function bh(a,b,c,d){var _=this
_.a=a
_.b=b
_.c=c
_.d=d},
dw:function dw(a,b){this.a=a
this.b=b},
dt:function dt(a,b){this.a=a
this.b=b},
du:function du(a){this.a=a},
dv:function dv(a){this.a=a},
E:function E(){},
cu:function cu(a,b){this.a=a
this.b=b},
b5:function b5(a,b,c){this.c=a
this.a=b
this.b=c},
cW:function cW(){},
cX:function cX(){},
cV:function cV(){},
b8:function b8(a,b){this.a=a
this.b=b},
ba:function ba(a,b){var _=this
_.d=_.c=null
_.a=a
_.b=b},
d_:function d_(a,b){this.a=a
this.b=b},
d0:function d0(a,b,c){this.a=a
this.b=b
this.c=c},
cY:function cY(a,b){this.a=a
this.b=b},
cZ:function cZ(a,b,c){this.a=a
this.b=b
this.c=c},
bc:function bc(a,b,c){var _=this
_.c=null
_.d=a
_.a=b
_.b=c},
bu:function bu(a,b){this.a=a
this.b=b},
bw:function bw(a,b){this.a=a
this.b=b},
bx:function bx(a,b,c){var _=this
_.c=a
_.e=_.d=null
_.a=b
_.b=c},
dY:function dY(a){this.a=a},
dZ:function dZ(a){this.a=a},
e_:function e_(a){this.a=a},
dW:function dW(){},
dX:function dX(a){this.a=a},
by:function by(a,b){this.a=a
this.b=b},
bz:function bz(a,b){this.a=a
this.b=b},
bA:function bA(a,b,c,d){var _=this
_.d=_.c=null
_.e=a
_.f=b
_.a=c
_.b=d},
e4:function e4(a){this.a=a},
e5:function e5(a){this.a=a},
e6:function e6(a){this.a=a},
a1(a){var s={}
s.on=a
s.version="1.0.0"
return s},
dE(a){var s,r,q=t.c.a(a.types)
q=t.a.b(q)?q:new A.a9(q,A.P(q).h("a9<1,k>"))
q=J.cU(q,new A.dF(),t.N)
s=q.$ti
r=s.h("M<G.E,L>")
return A.ab(new A.M(q,s.h("L(G.E)").a(new A.dG()),r),!0,r.h("G.E"))},
h_(a){var s=t.c.a(a.accounts)
s=t.cx.b(s)?s:new A.a9(s,A.P(s).h("a9<1,f>"))
s=J.cU(s,new A.dz(),t.N)
return A.ab(s,!0,s.$ti.h("G.E"))},
dF:function dF(){},
dG:function dG(){},
dz:function dz(){},
c1(a){A.hV(new A.cj("Field '"+a+"' has been assigned during initialization."),new Error())},
im(a,b,c){var s,r,q
if(a===b)return!0
for(s=0;s<2;++s){r=a[s]
q=b[s]
if(r!==q)return!1}return!0},
fU(a){var s,r,q,p
for(s=J.b3(a),r=t.R,q=12;s.l();){p=s.gm()
q=r.b(p)?(q^A.fU(p))>>>0:(q^J.a5(p))>>>0}return q},
iZ(a,b,c){var s,r,q=null
try{s=B.a.dt(a,b)
return s}catch(r){if(A.ao(r) instanceof A.aT){s=q
s=s==null?null:s.$0()
return s}else throw r}},
fZ(a){var s={}
s.showBalanceChanges=A.ax(a.showBalanceChanges)
s.showEffects=A.ax(a.showEffects)
s.showEvents=A.ax(a.showEvents)
s.showInput=A.ax(a.showInput)
s.showObjectChanges=A.ax(a.showObjectChanges)
s.showRawEffects=A.ax(a.showRawEffects)
s.showRawInput=A.ax(a.showRawInput)
return s},
dx(a){return A.iE(a)},
iE(a){var s=0,r=A.Z(t.K),q,p=2,o=[],n,m,l,k,j,i
var $async$dx=A.a_(function(b,c){if(b===1){o.push(c)
s=p}while(true)switch(s){case 0:p=4
s=a.transaction!=null?7:8
break
case 7:l=t.m
s=9
return A.a4(A.hT(l.a(a.transaction.toJSON()),t.N),$async$dx)
case 9:n=c
k={}
k.chain=A.h(a.chain)
k.account=A.h(l.a(a.account).address)
k.transaction=n
k.requestType=A.ak(a.requestType)
l=a.options
l=l==null?null:A.fZ(l)
k.options=l
q=k
s=1
break
case 8:if(a.transactionBlock!=null){m=t.K.a(a.transactionBlock.blockData)
k={}
k.chain=A.h(a.chain)
l=t.m
k.account=A.h(l.a(a.account).address)
k.transaction=A.h(l.a(self.JSON).stringify(m))
k.requestType=A.ak(a.requestType)
l=a.options
l=l==null?null:A.fZ(l)
k.options=l
q=k
s=1
break}p=2
s=6
break
case 4:p=3
i=o.pop()
s=6
break
case 3:s=2
break
case 6:throw A.d($.i_())
case 1:return A.X(q,r)
case 2:return A.W(o.at(-1),r)}})
return A.Y($async$dx,r)},
hf(a){var s={}
s.signTransaction=a
s.version="1.0.0"
return s},
dJ(a){var s=[],r=A.iw(a,"Array")
if(r){t.c.a(a)
s=a}else s.push(a)
return A.iJ(s,!0,t.K)}},B={}
var w=[A,J,B]
var $={}
A.fi.prototype={}
J.cd.prototype={
S(a,b){return a===b},
gt(a){return A.cx(a)},
i(a){return"Instance of '"+A.dQ(a)+"'"},
gu(a){return A.aH(A.fB(this))}}
J.ce.prototype={
i(a){return String(a)},
gt(a){return a?519018:218159},
gu(a){return A.aH(t.y)},
$iq:1,
$iy:1}
J.bg.prototype={
S(a,b){return null==b},
i(a){return"null"},
gt(a){return 0},
$iq:1,
$iB:1}
J.x.prototype={$if:1}
J.au.prototype={
gt(a){return 0},
i(a){return String(a)}}
J.cw.prototype={}
J.bB.prototype={}
J.z.prototype={
i(a){var s=a[$.b2()]
if(s==null)return this.bL(a)
return"JavaScript function for "+J.b4(s)},
$iaB:1}
J.aM.prototype={
gt(a){return 0},
i(a){return String(a)}}
J.aN.prototype={
gt(a){return 0},
i(a){return String(a)}}
J.l.prototype={
q(a,b){A.P(a).c.a(b)
a.$flags&1&&A.cS(a,29)
a.push(b)},
X(a,b){var s
a.$flags&1&&A.cS(a,"remove",1)
for(s=0;s<a.length;++s)if(J.fb(a[s],b)){a.splice(s,1)
return!0}return!1},
bt(a,b){var s
A.P(a).h("i<1>").a(b)
a.$flags&1&&A.cS(a,"addAll",2)
if(Array.isArray(b)){this.bQ(a,b)
return}for(s=J.b3(b);s.l();)a.push(s.gm())},
bQ(a,b){var s,r
t.b.a(b)
s=b.length
if(s===0)return
if(a===b)throw A.d(A.aq(a))
for(r=0;r<s;++r)a.push(b[r])},
aw(a,b,c){var s=A.P(a)
return new A.M(a,s.n(c).h("1(2)").a(b),s.h("@<1>").n(c).h("M<1,2>"))},
ae(a,b){var s,r=A.h4(a.length,"",!1,t.N)
for(s=0;s<a.length;++s)this.C(r,s,A.w(a[s]))
return r.join(b)},
W(a,b,c){var s,r,q,p=A.P(a)
p.h("y(1)").a(b)
p.h("1()?").a(c)
s=a.length
for(r=0;r<s;++r){q=a[r]
if(A.hM(b.$1(q)))return q
if(a.length!==s)throw A.d(A.aq(a))}if(c!=null)return c.$0()
throw A.d(A.iu())},
dt(a,b){return this.W(a,b,null)},
P(a,b){if(!(b>=0&&b<a.length))return A.J(a,b)
return a[b]},
a3(a,b,c){var s=a.length
if(b>s)throw A.d(A.aE(b,0,s,"start",null))
if(c==null)c=s
else if(c<b||c>s)throw A.d(A.aE(c,b,s,"end",null))
if(b===c)return A.a([],A.P(a))
return A.a(a.slice(b,c),A.P(a))},
bI(a,b){return this.a3(a,b,null)},
ds(a,b){var s
for(s=0;s<a.length;++s)if(J.fb(a[s],b))return!0
return!1},
i(a){return A.fW(a,"[","]")},
gB(a){return new J.b6(a,a.length,A.P(a).h("b6<1>"))},
gt(a){return A.cx(a)},
gp(a){return a.length},
j(a,b){if(!(b>=0&&b<a.length))throw A.d(A.eY(a,b))
return a[b]},
C(a,b,c){A.P(a).c.a(c)
a.$flags&2&&A.cS(a)
if(!(b>=0&&b<a.length))throw A.d(A.eY(a,b))
a[b]=c},
$ij:1,
$ii:1,
$im:1}
J.dy.prototype={}
J.b6.prototype={
gm(){var s=this.d
return s==null?this.$ti.c.a(s):s},
l(){var s,r=this,q=r.a,p=q.length
if(r.b!==p){q=A.c0(q)
throw A.d(q)}s=r.c
if(s>=p){r.sb7(null)
return!1}r.sb7(q[s]);++r.c
return!0},
sb7(a){this.d=this.$ti.h("1?").a(a)},
$iT:1}
J.cg.prototype={
dJ(a,b){var s,r,q,p,o
if(b<2||b>36)throw A.d(A.aE(b,2,36,"radix",null))
s=a.toString(b)
r=s.length
q=r-1
if(!(q>=0))return A.J(s,q)
if(s.charCodeAt(q)!==41)return s
p=/^([\da-z]+)(?:\.([\da-z]+))?\(e\+(\d+)\)$/.exec(s)
if(p==null)A.an(A.ef("Unexpected toString result: "+s))
r=p.length
if(1>=r)return A.J(p,1)
s=p[1]
if(3>=r)return A.J(p,3)
o=+p[3]
r=p[2]
if(r!=null){s+=r
o-=r.length}return s+B.l.aW("0",o)},
i(a){if(a===0&&1/a<0)return"-0.0"
else return""+a},
gt(a){var s,r,q,p,o=a|0
if(a===o)return o&536870911
s=Math.abs(a)
r=Math.log(s)/0.6931471805599453|0
q=Math.pow(2,r)
p=s<1?s/q:q/s
return((p*9007199254740992|0)+(p*3542243181176521|0))*599197+r*1259&536870911},
cS(a,b){var s
if(a>0)s=this.cR(a,b)
else{s=b>31?31:b
s=a>>s>>>0}return s},
cR(a,b){return b>31?0:a>>>b},
gu(a){return A.aH(t.q)},
$it:1,
$ib1:1}
J.bf.prototype={
gu(a){return A.aH(t.S)},
$iq:1,
$ic:1}
J.cf.prototype={
gu(a){return A.aH(t.i)},
$iq:1}
J.aL.prototype={
bH(a,b){var s=b.length
if(s>a.length)return!1
return b===a.substring(0,s)},
bK(a,b,c){return a.substring(b,A.j0(b,c,a.length))},
bJ(a,b){return this.bK(a,b,null)},
aW(a,b){var s,r
if(0>=b)return""
if(b===1||a.length===0)return a
if(b!==b>>>0)throw A.d(B.W)
for(s=a,r="";!0;){if((b&1)===1)r=s+r
b=b>>>1
if(b===0)break
s+=s}return r},
bw(a,b,c){var s=b-a.length
if(s<=0)return a
return this.aW(c,s)+a},
i(a){return a},
gt(a){var s,r,q
for(s=a.length,r=0,q=0;q<s;++q){r=r+a.charCodeAt(q)&536870911
r=r+((r&524287)<<10)&536870911
r^=r>>6}r=r+((r&67108863)<<3)&536870911
r^=r>>11
return r+((r&16383)<<15)&536870911},
gu(a){return A.aH(t.N)},
gp(a){return a.length},
$iq:1,
$ih6:1,
$ik:1}
A.aU.prototype={
gB(a){return new A.b9(J.b3(this.gaq()),A.H(this).h("b9<1,2>"))},
gp(a){return J.cT(this.gaq())},
P(a,b){return A.H(this).y[1].a(J.fN(this.gaq(),b))},
i(a){return J.b4(this.gaq())}}
A.b9.prototype={
l(){return this.a.l()},
gm(){return this.$ti.y[1].a(this.a.gm())},
$iT:1}
A.bF.prototype={
j(a,b){return this.$ti.y[1].a(J.ib(this.a,b))},
$ij:1,
$im:1}
A.a9.prototype={
gaq(){return this.a}}
A.cj.prototype={
i(a){return"LateInitializationError: "+this.a}}
A.dV.prototype={}
A.j.prototype={}
A.G.prototype={
gB(a){var s=this
return new A.aC(s,s.gp(s),A.H(s).h("aC<G.E>"))},
aw(a,b,c){var s=A.H(this)
return new A.M(this,s.n(c).h("1(G.E)").a(b),s.h("@<G.E>").n(c).h("M<1,2>"))}}
A.aC.prototype={
gm(){var s=this.d
return s==null?this.$ti.c.a(s):s},
l(){var s,r=this,q=r.a,p=J.hO(q),o=p.gp(q)
if(r.b!==o)throw A.d(A.aq(q))
s=r.c
if(s>=o){r.sa4(null)
return!1}r.sa4(p.P(q,s));++r.c
return!0},
sa4(a){this.d=this.$ti.h("1?").a(a)},
$iT:1}
A.aD.prototype={
gB(a){var s=this.a
return new A.bm(s.gB(s),this.b,A.H(this).h("bm<1,2>"))},
gp(a){var s=this.a
return s.gp(s)},
P(a,b){var s=this.a
return this.b.$1(s.P(s,b))}}
A.bb.prototype={$ij:1}
A.bm.prototype={
l(){var s=this,r=s.b
if(r.l()){s.sa4(s.c.$1(r.gm()))
return!0}s.sa4(null)
return!1},
gm(){var s=this.a
return s==null?this.$ti.y[1].a(s):s},
sa4(a){this.a=this.$ti.h("2?").a(a)},
$iT:1}
A.M.prototype={
gp(a){return J.cT(this.a)},
P(a,b){return this.b.$1(J.fN(this.a,b))}}
A.K.prototype={}
A.bV.prototype={}
A.e7.prototype={
O(a){var s,r,q=this,p=new RegExp(q.a).exec(a)
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
A.bt.prototype={
i(a){return"Null check operator used on a null value"}}
A.ci.prototype={
i(a){var s,r=this,q="NoSuchMethodError: method not found: '",p=r.b
if(p==null)return"NoSuchMethodError: "+r.a
s=r.c
if(s==null)return q+p+"' ("+r.a+")"
return q+p+"' on '"+s+"' ("+r.a+")"}}
A.cD.prototype={
i(a){var s=this.a
return s.length===0?"Error":"Error: "+s}}
A.dP.prototype={
i(a){return"Throw of null ('"+(this.a===null?"null":"undefined")+"' from JavaScript)"}}
A.bd.prototype={}
A.bN.prototype={
i(a){var s,r=this.b
if(r!=null)return r
r=this.a
s=r!==null&&typeof r==="object"?r.stack:null
return this.b=s==null?"":s},
$ia2:1}
A.ap.prototype={
i(a){var s=this.constructor,r=s==null?null:s.name
return"Closure '"+A.hW(r==null?"unknown":r)+"'"},
$iaB:1,
gdP(){return this},
$C:"$1",
$R:1,
$D:null}
A.c4.prototype={$C:"$0",$R:0}
A.c5.prototype={$C:"$2",$R:2}
A.cB.prototype={}
A.cz.prototype={
i(a){var s=this.$static_name
if(s==null)return"Closure of unknown static method"
return"Closure '"+A.hW(s)+"'"}}
A.aK.prototype={
S(a,b){if(b==null)return!1
if(this===b)return!0
if(!(b instanceof A.aK))return!1
return this.$_target===b.$_target&&this.a===b.a},
gt(a){return(A.cR(this.a)^A.cx(this.$_target))>>>0},
i(a){return"Closure '"+this.$_name+"' of "+("Instance of '"+A.dQ(this.a)+"'")}}
A.cG.prototype={
i(a){return"Reading static variable '"+this.a+"' during its initialization"}}
A.cy.prototype={
i(a){return"RuntimeError: "+this.a}}
A.cE.prototype={
i(a){return"Assertion failed: "+A.cb(this.a)}}
A.aa.prototype={
gp(a){return this.a},
gaf(){return new A.bl(this,A.H(this).h("bl<1>"))},
a0(a){var s=this.dz(a)
return s},
dz(a){var s=this.d
if(s==null)return!1
return this.av(s[this.au(a)],a)>=0},
j(a,b){var s,r,q,p,o=null
if(typeof b=="string"){s=this.b
if(s==null)return o
r=s[b]
q=r==null?o:r.b
return q}else if(typeof b=="number"&&(b&0x3fffffff)===b){p=this.c
if(p==null)return o
r=p[b]
q=r==null?o:r.b
return q}else return this.dA(b)},
dA(a){var s,r,q=this.d
if(q==null)return null
s=q[this.au(a)]
r=this.av(s,a)
if(r<0)return null
return s[r].b},
C(a,b,c){var s,r,q=this,p=A.H(q)
p.c.a(b)
p.y[1].a(c)
if(typeof b=="string"){s=q.b
q.aZ(s==null?q.b=q.aL():s,b,c)}else if(typeof b=="number"&&(b&0x3fffffff)===b){r=q.c
q.aZ(r==null?q.c=q.aL():r,b,c)}else q.dC(b,c)},
dC(a,b){var s,r,q,p,o=this,n=A.H(o)
n.c.a(a)
n.y[1].a(b)
s=o.d
if(s==null)s=o.d=o.aL()
r=o.au(a)
q=s[r]
if(q==null)s[r]=[o.aM(a,b)]
else{p=o.av(q,a)
if(p>=0)q[p].b=b
else q.push(o.aM(a,b))}},
X(a,b){var s=this
if(typeof b=="string")return s.bl(s.b,b)
else if(typeof b=="number"&&(b&0x3fffffff)===b)return s.bl(s.c,b)
else return s.dB(b)},
dB(a){var s,r,q,p,o=this,n=o.d
if(n==null)return null
s=o.au(a)
r=n[s]
q=o.av(r,a)
if(q<0)return null
p=r.splice(q,1)[0]
o.br(p)
if(r.length===0)delete n[s]
return p.b},
ad(a,b){var s,r,q=this
A.H(q).h("~(1,2)").a(b)
s=q.e
r=q.r
for(;s!=null;){b.$2(s.a,s.b)
if(r!==q.r)throw A.d(A.aq(q))
s=s.c}},
aZ(a,b,c){var s,r=A.H(this)
r.c.a(b)
r.y[1].a(c)
s=a[b]
if(s==null)a[b]=this.aM(b,c)
else s.b=c},
bl(a,b){var s
if(a==null)return null
s=a[b]
if(s==null)return null
this.br(s)
delete a[b]
return s.b},
bh(){this.r=this.r+1&1073741823},
aM(a,b){var s=this,r=A.H(s),q=new A.dK(r.c.a(a),r.y[1].a(b))
if(s.e==null)s.e=s.f=q
else{r=s.f
r.toString
q.d=r
s.f=r.c=q}++s.a
s.bh()
return q},
br(a){var s=this,r=a.d,q=a.c
if(r==null)s.e=q
else r.c=q
if(q==null)s.f=r
else q.d=r;--s.a
s.bh()},
au(a){return J.a5(a)&1073741823},
av(a,b){var s,r
if(a==null)return-1
s=a.length
for(r=0;r<s;++r)if(J.fb(a[r].a,b))return r
return-1},
i(a){return A.fl(this)},
aL(){var s=Object.create(null)
s["<non-identifier-key>"]=s
delete s["<non-identifier-key>"]
return s},
$ih2:1}
A.dK.prototype={}
A.bl.prototype={
gp(a){return this.a.a},
gB(a){var s=this.a
return new A.bk(s,s.r,s.e,this.$ti.h("bk<1>"))}}
A.bk.prototype={
gm(){return this.d},
l(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.d(A.aq(q))
s=r.c
if(s==null){r.sa5(null)
return!1}else{r.sa5(s.a)
r.c=s.c
return!0}},
sa5(a){this.d=this.$ti.h("1?").a(a)},
$iT:1}
A.bi.prototype={
gp(a){return this.a.a},
gB(a){var s=this.a
return new A.bj(s,s.r,s.e,this.$ti.h("bj<1,2>"))}}
A.bj.prototype={
gm(){var s=this.d
s.toString
return s},
l(){var s,r=this,q=r.a
if(r.b!==q.r)throw A.d(A.aq(q))
s=r.c
if(s==null){r.sa5(null)
return!1}else{r.sa5(new A.ad(s.a,s.b,r.$ti.h("ad<1,2>")))
r.c=s.c
return!0}},
sa5(a){this.d=this.$ti.h("ad<1,2>?").a(a)},
$iT:1}
A.f0.prototype={
$1(a){return this.a(a)},
$S:25}
A.f1.prototype={
$2(a,b){return this.a(a,b)},
$S:57}
A.f2.prototype={
$1(a){return this.a(A.h(a))},
$S:43}
A.cJ.prototype={}
A.bn.prototype={
gu(a){return B.a8},
bu(a,b,c){var s=new Uint8Array(a,b,c)
return s},
$iq:1,
$ibn:1,
$ic3:1}
A.br.prototype={
gdn(a){if(((a.$flags|0)&2)!==0)return new A.cO(a.buffer)
else return a.buffer}}
A.cO.prototype={
bu(a,b,c){var s=A.iN(this.a,b,c)
s.$flags=3
return s},
$ic3:1}
A.bo.prototype={
gu(a){return B.a9},
$iq:1,
$ife:1}
A.aP.prototype={
gp(a){return a.length},
$iQ:1}
A.bp.prototype={
j(a,b){A.aG(b,a,a.length)
return a[b]},
$ij:1,
$ii:1,
$im:1}
A.bq.prototype={$ij:1,$ii:1,$im:1}
A.ck.prototype={
gu(a){return B.aa},
$iq:1,
$id3:1}
A.cl.prototype={
gu(a){return B.ab},
$iq:1,
$id4:1}
A.cm.prototype={
gu(a){return B.ac},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$iq:1,
$id9:1}
A.cn.prototype={
gu(a){return B.ad},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$iq:1,
$ida:1}
A.co.prototype={
gu(a){return B.ae},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$iq:1,
$idb:1}
A.cp.prototype={
gu(a){return B.ag},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$iq:1,
$ieb:1}
A.cq.prototype={
gu(a){return B.ah},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$iq:1,
$iec:1}
A.bs.prototype={
gu(a){return B.ai},
gp(a){return a.length},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$iq:1,
$ied:1}
A.cr.prototype={
gu(a){return B.aj},
gp(a){return a.length},
j(a,b){A.aG(b,a,a.length)
return a[b]},
$iq:1,
$iee:1}
A.bJ.prototype={}
A.bK.prototype={}
A.bL.prototype={}
A.bM.prototype={}
A.V.prototype={
h(a){return A.bT(v.typeUniverse,this,a)},
n(a){return A.hv(v.typeUniverse,this,a)}}
A.cI.prototype={}
A.eN.prototype={
i(a){return A.I(this.a,null)}}
A.cH.prototype={
i(a){return this.a}}
A.bP.prototype={$iaf:1}
A.em.prototype={
$1(a){var s=this.a,r=s.a
s.a=null
r.$0()},
$S:6}
A.el.prototype={
$1(a){var s,r
this.a.a=t.M.a(a)
s=this.b
r=this.c
s.firstChild?s.removeChild(r):s.appendChild(r)},
$S:42}
A.en.prototype={
$0(){this.a.$0()},
$S:24}
A.eo.prototype={
$0(){this.a.$0()},
$S:24}
A.eL.prototype={
bO(a,b){if(self.setTimeout!=null)this.b=self.setTimeout(A.bY(new A.eM(this,b),0),a)
else throw A.d(A.ef("`setTimeout()` not found."))},
bv(){if(self.setTimeout!=null){var s=this.b
if(s==null)return
self.clearTimeout(s)
this.b=null}else throw A.d(A.ef("Canceling a timer."))}}
A.eM.prototype={
$0(){this.a.b=null
this.b.$0()},
$S:2}
A.bE.prototype={
V(a){var s,r=this,q=r.$ti
q.h("1/?").a(a)
if(a==null)a=q.c.a(a)
if(!r.b)r.a.aF(a)
else{s=r.a
if(q.h("F<1>").b(a))s.b1(a)
else s.ak(a)}},
aS(a,b){var s=this.a
if(this.b)s.G(a,b)
else s.aG(a,b)},
$ic6:1}
A.eP.prototype={
$1(a){return this.a.$2(0,a)},
$S:16}
A.eQ.prototype={
$2(a,b){this.a.$2(1,new A.bd(a,t.l.a(b)))},
$S:40}
A.eT.prototype={
$2(a,b){this.a(A.a3(a),b)},
$S:51}
A.a8.prototype={
i(a){return A.w(this.a)},
$iu:1,
ga2(){return this.b}}
A.d8.prototype={
$0(){this.c.a(null)
this.b.b4(null)},
$S:2}
A.e3.prototype={
i(a){var s=A.w(this.b)
return"TimeoutException after "+s+": "+this.a}}
A.aV.prototype={
aS(a,b){var s
if((this.a.a&30)!==0)throw A.d(A.fn("Future already completed"))
s=A.jH(a,b)
this.G(s.a,s.b)},
aR(a){return this.aS(a,null)},
$ic6:1}
A.ah.prototype={
V(a){var s,r=this.$ti
r.h("1/?").a(a)
s=this.a
if((s.a&30)!==0)throw A.d(A.fn("Future already completed"))
s.aF(r.h("1/").a(a))},
aQ(){return this.V(null)},
G(a,b){this.a.aG(a,b)}}
A.bO.prototype={
V(a){var s,r=this.$ti
r.h("1/?").a(a)
s=this.a
if((s.a&30)!==0)throw A.d(A.fn("Future already completed"))
s.b4(r.h("1/").a(a))},
aQ(){return this.V(null)},
G(a,b){this.a.G(a,b)}}
A.ai.prototype={
dD(a){if((this.c&15)!==6)return!0
return this.b.b.aV(t.bG.a(this.d),a.a,t.y,t.K)},
du(a){var s,r=this,q=r.e,p=null,o=t.z,n=t.K,m=a.a,l=r.b.b
if(t.Q.b(q))p=l.dG(q,m,a.b,o,n,t.l)
else p=l.aV(t.v.a(q),m,o,n)
try{o=r.$ti.h("2/").a(p)
return o}catch(s){if(t.b7.b(A.ao(s))){if((r.c&1)!==0)throw A.d(A.a7("The error handler of Future.then must return a value of the returned future's type","onError"))
throw A.d(A.a7("The error handler of Future.catchError must return a value of the future's type","onError"))}else throw s}}}
A.n.prototype={
Y(a,b,c){var s,r,q,p=this.$ti
p.n(c).h("1/(2)").a(a)
s=$.o
if(s===B.e){if(b!=null&&!t.Q.b(b)&&!t.v.b(b))throw A.d(A.fc(b,"onError",u.c))}else{c.h("@<0/>").n(p.c).h("1(2)").a(a)
if(b!=null)b=A.hG(b,s)}r=new A.n(s,c.h("n<0>"))
q=b==null?1:3
this.ai(new A.ai(r,q,a,b,p.h("@<1>").n(c).h("ai<1,2>")))
return r},
ah(a,b){return this.Y(a,null,b)},
bq(a,b,c){var s,r=this.$ti
r.n(c).h("1/(2)").a(a)
s=new A.n($.o,c.h("n<0>"))
this.ai(new A.ai(s,19,a,b,r.h("@<1>").n(c).h("ai<1,2>")))
return s},
cQ(a){this.a=this.a&1|16
this.c=a},
aj(a){this.a=a.a&30|this.a&1
this.c=a.c},
ai(a){var s,r=this,q=r.a
if(q<=3){a.a=t.F.a(r.c)
r.c=a}else{if((q&4)!==0){s=t.d.a(r.c)
if((s.a&24)===0){s.ai(a)
return}r.aj(s)}A.aY(null,null,r.b,t.M.a(new A.er(r,a)))}},
bk(a){var s,r,q,p,o,n,m=this,l={}
l.a=a
if(a==null)return
s=m.a
if(s<=3){r=t.F.a(m.c)
m.c=a
if(r!=null){q=a.a
for(p=a;q!=null;p=q,q=o)o=q.a
p.a=r}}else{if((s&4)!==0){n=t.d.a(m.c)
if((n.a&24)===0){n.bk(a)
return}m.aj(n)}l.a=m.ap(a)
A.aY(null,null,m.b,t.M.a(new A.ez(l,m)))}},
aa(){var s=t.F.a(this.c)
this.c=null
return this.ap(s)},
ap(a){var s,r,q
for(s=a,r=null;s!=null;r=s,s=q){q=s.a
s.a=r}return r},
b0(a){var s,r,q,p=this
p.a^=2
try{a.Y(new A.ew(p),new A.ex(p),t.P)}catch(q){s=A.ao(q)
r=A.az(q)
A.kp(new A.ey(p,s,r))}},
b4(a){var s,r=this,q=r.$ti
q.h("1/").a(a)
if(q.h("F<1>").b(a))if(q.b(a))A.eu(a,r,!0)
else r.b0(a)
else{s=r.aa()
q.c.a(a)
r.a=8
r.c=a
A.aF(r,s)}},
ak(a){var s,r=this
r.$ti.c.a(a)
s=r.aa()
r.a=8
r.c=a
A.aF(r,s)},
c3(a){var s,r,q=this
if((a.a&16)!==0){s=q.b===a.b
s=!(s||s)}else s=!1
if(s)return
r=q.aa()
q.aj(a)
A.aF(q,r)},
G(a,b){var s
t.l.a(b)
s=this.aa()
this.cQ(new A.a8(a,b))
A.aF(this,s)},
aF(a){var s=this.$ti
s.h("1/").a(a)
if(s.h("F<1>").b(a)){this.b1(a)
return}this.bV(a)},
bV(a){var s=this
s.$ti.c.a(a)
s.a^=2
A.aY(null,null,s.b,t.M.a(new A.et(s,a)))},
b1(a){var s=this.$ti
s.h("F<1>").a(a)
if(s.b(a)){A.eu(a,this,!1)
return}this.b0(a)},
aG(a,b){this.a^=2
A.aY(null,null,this.b,t.M.a(new A.es(this,a,b)))},
dI(a){var s,r=this,q={}
if((r.a&24)!==0){q=new A.n($.o,r.$ti)
q.aF(r)
return q}s=new A.n($.o,r.$ti)
q.a=null
q.a=A.he(a,new A.eF(s,a))
r.Y(new A.eG(q,r,s),new A.eH(q,s),t.P)
return s},
$iF:1}
A.er.prototype={
$0(){A.aF(this.a,this.b)},
$S:2}
A.ez.prototype={
$0(){A.aF(this.b,this.a.a)},
$S:2}
A.ew.prototype={
$1(a){var s,r,q,p=this.a
p.a^=2
try{p.ak(p.$ti.c.a(a))}catch(q){s=A.ao(q)
r=A.az(q)
p.G(s,r)}},
$S:6}
A.ex.prototype={
$2(a,b){this.a.G(t.K.a(a),t.l.a(b))},
$S:8}
A.ey.prototype={
$0(){this.a.G(this.b,this.c)},
$S:2}
A.ev.prototype={
$0(){A.eu(this.a.a,this.b,!0)},
$S:2}
A.et.prototype={
$0(){this.a.ak(this.b)},
$S:2}
A.es.prototype={
$0(){this.a.G(this.b,this.c)},
$S:2}
A.eC.prototype={
$0(){var s,r,q,p,o,n,m,l,k=this,j=null
try{q=k.a.a
j=q.b.b.dF(t.bd.a(q.d),t.z)}catch(p){s=A.ao(p)
r=A.az(p)
if(k.c&&t.n.a(k.b.a.c).a===s){q=k.a
q.c=t.n.a(k.b.a.c)}else{q=s
o=r
if(o==null)o=A.fd(q)
n=k.a
n.c=new A.a8(q,o)
q=n}q.b=!0
return}if(j instanceof A.n&&(j.a&24)!==0){if((j.a&16)!==0){q=k.a
q.c=t.n.a(j.c)
q.b=!0}return}if(j instanceof A.n){m=k.b.a
l=new A.n(m.b,m.$ti)
j.Y(new A.eD(l,m),new A.eE(l),t.H)
q=k.a
q.c=l
q.b=!1}},
$S:2}
A.eD.prototype={
$1(a){this.a.c3(this.b)},
$S:6}
A.eE.prototype={
$2(a,b){this.a.G(t.K.a(a),t.l.a(b))},
$S:8}
A.eB.prototype={
$0(){var s,r,q,p,o,n,m,l
try{q=this.a
p=q.a
o=p.$ti
n=o.c
m=n.a(this.b)
q.c=p.b.b.aV(o.h("2/(1)").a(p.d),m,o.h("2/"),n)}catch(l){s=A.ao(l)
r=A.az(l)
q=s
p=r
if(p==null)p=A.fd(q)
o=this.a
o.c=new A.a8(q,p)
o.b=!0}},
$S:2}
A.eA.prototype={
$0(){var s,r,q,p,o,n,m,l=this
try{s=t.n.a(l.a.a.c)
p=l.b
if(p.a.dD(s)&&p.a.e!=null){p.c=p.a.du(s)
p.b=!1}}catch(o){r=A.ao(o)
q=A.az(o)
p=t.n.a(l.a.a.c)
if(p.a===r){n=l.b
n.c=p
p=n}else{p=r
n=q
if(n==null)n=A.fd(p)
m=l.b
m.c=new A.a8(p,n)
p=m}p.b=!0}},
$S:2}
A.eF.prototype={
$0(){this.a.G(new A.e3("Future not completed",this.b),A.hc())},
$S:2}
A.eG.prototype={
$1(a){var s
this.b.$ti.c.a(a)
s=this.a.a
if(s.b!=null){s.bv()
this.c.ak(a)}},
$S(){return this.b.$ti.h("B(1)")}}
A.eH.prototype={
$2(a,b){var s
t.K.a(a)
t.l.a(b)
s=this.a.a
if(s.b!=null){s.bv()
this.b.G(a,b)}},
$S:8}
A.cF.prototype={}
A.cL.prototype={}
A.bU.prototype={$ihj:1}
A.eS.prototype={
$0(){A.ir(this.a,this.b)},
$S:2}
A.cK.prototype={
dH(a){var s,r,q
t.M.a(a)
try{if(B.e===$.o){a.$0()
return}A.hH(null,null,this,a,t.H)}catch(q){s=A.ao(q)
r=A.az(q)
A.fD(t.K.a(s),t.l.a(r))}},
aP(a){return new A.eK(this,t.M.a(a))},
dF(a,b){b.h("0()").a(a)
if($.o===B.e)return a.$0()
return A.hH(null,null,this,a,b)},
aV(a,b,c,d){c.h("@<0>").n(d).h("1(2)").a(a)
d.a(b)
if($.o===B.e)return a.$1(b)
return A.jW(null,null,this,a,b,c,d)},
dG(a,b,c,d,e,f){d.h("@<0>").n(e).n(f).h("1(2,3)").a(a)
e.a(b)
f.a(c)
if($.o===B.e)return a.$2(b,c)
return A.jV(null,null,this,a,b,c,d,e,f)},
by(a,b,c,d){return b.h("@<0>").n(c).n(d).h("1(2,3)").a(a)}}
A.eK.prototype={
$0(){return this.a.dH(this.b)},
$S:2}
A.bG.prototype={
gp(a){return this.a},
gaf(){return new A.bH(this,this.$ti.h("bH<1>"))},
a0(a){var s,r
if(typeof a=="string"&&a!=="__proto__"){s=this.b
return s==null?!1:s[a]!=null}else if(typeof a=="number"&&(a&1073741823)===a){r=this.c
return r==null?!1:r[a]!=null}else return this.c8(a)},
c8(a){var s=this.d
if(s==null)return!1
return this.am(this.b8(s,a),a)>=0},
j(a,b){var s,r,q
if(typeof b=="string"&&b!=="__proto__"){s=this.b
r=s==null?null:A.fs(s,b)
return r}else if(typeof b=="number"&&(b&1073741823)===b){q=this.c
r=q==null?null:A.fs(q,b)
return r}else return this.cg(b)},
cg(a){var s,r,q=this.d
if(q==null)return null
s=this.b8(q,a)
r=this.am(s,a)
return r<0?null:s[r+1]},
C(a,b,c){var s,r,q,p,o,n,m=this,l=m.$ti
l.c.a(b)
l.y[1].a(c)
if(typeof b=="string"&&b!=="__proto__"){s=m.b
m.b_(s==null?m.b=A.ft():s,b,c)}else if(typeof b=="number"&&(b&1073741823)===b){r=m.c
m.b_(r==null?m.c=A.ft():r,b,c)}else{q=m.d
if(q==null)q=m.d=A.ft()
p=A.cR(b)&1073741823
o=q[p]
if(o==null){A.fu(q,p,[b,c]);++m.a
m.e=null}else{n=m.am(o,b)
if(n>=0)o[n+1]=c
else{o.push(b,c);++m.a
m.e=null}}}},
X(a,b){var s=this
if(typeof b=="string"&&b!=="__proto__")return s.b3(s.b,b)
else if(typeof b=="number"&&(b&1073741823)===b)return s.b3(s.c,b)
else return s.cH(b)},
cH(a){var s,r,q,p,o=this,n=o.d
if(n==null)return null
s=A.cR(a)&1073741823
r=n[s]
q=o.am(r,a)
if(q<0)return null;--o.a
o.e=null
p=r.splice(q,2)[1]
if(0===r.length)delete n[s]
return p},
ad(a,b){var s,r,q,p,o,n,m=this,l=m.$ti
l.h("~(1,2)").a(b)
s=m.b5()
for(r=s.length,q=l.c,l=l.y[1],p=0;p<r;++p){o=s[p]
q.a(o)
n=m.j(0,o)
b.$2(o,n==null?l.a(n):n)
if(s!==m.e)throw A.d(A.aq(m))}},
b5(){var s,r,q,p,o,n,m,l,k,j,i=this,h=i.e
if(h!=null)return h
h=A.h4(i.a,null,!1,t.z)
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
b_(a,b,c){var s=this.$ti
s.c.a(b)
s.y[1].a(c)
if(a[b]==null){++this.a
this.e=null}A.fu(a,b,c)},
b3(a,b){var s
if(a!=null&&a[b]!=null){s=this.$ti.y[1].a(A.fs(a,b))
delete a[b];--this.a
this.e=null
return s}else return null},
b8(a,b){return a[A.cR(b)&1073741823]}}
A.aW.prototype={
am(a,b){var s,r,q
if(a==null)return-1
s=a.length
for(r=0;r<s;r+=2){q=a[r]
if(q==null?b==null:q===b)return r}return-1}}
A.bH.prototype={
gp(a){return this.a.a},
gB(a){var s=this.a
return new A.bI(s,s.b5(),this.$ti.h("bI<1>"))}}
A.bI.prototype={
gm(){var s=this.d
return s==null?this.$ti.c.a(s):s},
l(){var s=this,r=s.b,q=s.c,p=s.a
if(r!==p.e)throw A.d(A.aq(p))
else if(q>=r.length){s.sb2(null)
return!1}else{s.sb2(r[q])
s.c=q+1
return!0}},
sb2(a){this.d=this.$ti.h("1?").a(a)},
$iT:1}
A.dL.prototype={
$2(a,b){this.a.C(0,this.b.a(a),this.c.a(b))},
$S:29}
A.p.prototype={
gB(a){return new A.aC(a,this.gp(a),A.b0(a).h("aC<p.E>"))},
P(a,b){return this.j(a,b)},
aw(a,b,c){var s=A.b0(a)
return new A.M(a,s.n(c).h("1(p.E)").a(b),s.h("@<p.E>").n(c).h("M<1,2>"))},
i(a){return A.fW(a,"[","]")}}
A.ac.prototype={
ad(a,b){var s,r,q,p=A.H(this)
p.h("~(1,2)").a(b)
for(s=this.gaf(),s=s.gB(s),p=p.y[1];s.l();){r=s.gm()
q=this.j(0,r)
b.$2(r,q==null?p.a(q):q)}},
dE(a,b){var s,r,q,p,o,n=this,m=A.H(n)
m.h("y(1,2)").a(b)
s=A.a([],m.h("l<1>"))
for(r=n.gaf(),r=r.gB(r),m=m.y[1];r.l();){q=r.gm()
p=n.j(0,q)
if(A.hM(b.$2(q,p==null?m.a(p):p)))B.a.q(s,q)}for(m=s.length,o=0;o<s.length;s.length===m||(0,A.c0)(s),++o)n.X(0,s[o])},
gp(a){var s=this.gaf()
return s.gp(s)},
i(a){return A.fl(this)},
$iaO:1}
A.dN.prototype={
$2(a,b){var s,r=this.a
if(!r.a)this.b.a+=", "
r.a=!1
r=this.b
s=A.w(a)
s=r.a+=s
r.a=s+": "
s=A.w(b)
r.a+=s},
$S:47}
A.c8.prototype={
S(a,b){var s
if(b==null)return!1
s=!1
if(b instanceof A.c8)if(this.a===b.a)s=this.b===b.b
return s},
gt(a){return A.iO(this.a,this.b,B.n,B.n)},
i(a){var s=this,r=A.io(A.iX(s)),q=A.c9(A.iV(s)),p=A.c9(A.iR(s)),o=A.c9(A.iS(s)),n=A.c9(A.iU(s)),m=A.c9(A.iW(s)),l=A.fT(A.iT(s)),k=s.b,j=k===0?"":A.fT(k)
return r+"-"+q+"-"+p+" "+o+":"+n+":"+m+"."+l+j+"Z"}}
A.ca.prototype={
S(a,b){if(b==null)return!1
return b instanceof A.ca},
gt(a){return B.f.gt(0)},
i(a){return"0:00:00."+B.l.bw(B.f.i(0),6,"0")}}
A.ep.prototype={
i(a){return this.T()}}
A.u.prototype={
ga2(){return A.iQ(this)}}
A.b7.prototype={
i(a){var s=this.a
if(s!=null)return"Assertion failed: "+A.cb(s)
return"Assertion failed"}}
A.af.prototype={}
A.a6.prototype={
gaJ(){return"Invalid argument"+(!this.a?"(s)":"")},
gaI(){return""},
i(a){var s=this,r=s.c,q=r==null?"":" ("+r+")",p=s.d,o=p==null?"":": "+p,n=s.gaJ()+q+o
if(!s.a)return n
return n+s.gaI()+": "+A.cb(s.gaT())},
gaT(){return this.b}}
A.aS.prototype={
gaT(){return A.jp(this.b)},
gaJ(){return"RangeError"},
gaI(){var s,r=this.e,q=this.f
if(r==null)s=q!=null?": Not less than or equal to "+A.w(q):""
else if(q==null)s=": Not greater than or equal to "+A.w(r)
else if(q>r)s=": Not in inclusive range "+A.w(r)+".."+A.w(q)
else s=q<r?": Valid value range is empty":": Only valid value is "+A.w(r)
return s}}
A.cc.prototype={
gaT(){return A.a3(this.b)},
gaJ(){return"RangeError"},
gaI(){if(A.a3(this.b)<0)return": index must not be negative"
var s=this.f
if(s===0)return": no indices are valid"
return": index should be less than "+s},
gp(a){return this.f}}
A.bC.prototype={
i(a){return"Unsupported operation: "+this.a}}
A.cC.prototype={
i(a){var s=this.a
return s!=null?"UnimplementedError: "+s:"UnimplementedError"}}
A.aT.prototype={
i(a){return"Bad state: "+this.a}}
A.c7.prototype={
i(a){var s=this.a
if(s==null)return"Concurrent modification during iteration."
return"Concurrent modification during iteration: "+A.cb(s)+"."}}
A.cs.prototype={
i(a){return"Out of Memory"},
ga2(){return null},
$iu:1}
A.bv.prototype={
i(a){return"Stack Overflow"},
ga2(){return null},
$iu:1}
A.eq.prototype={
i(a){return"Exception: "+this.a}}
A.i.prototype={
aw(a,b,c){var s=A.H(this)
return A.iM(this,s.n(c).h("1(i.E)").a(b),s.h("i.E"),c)},
gp(a){var s,r=this.gB(this)
for(s=0;r.l();)++s
return s},
P(a,b){var s,r
A.j_(b,"index")
s=this.gB(this)
for(r=b;s.l();){if(r===0)return s.gm();--r}throw A.d(A.fV(b,b-r,this,"index"))},
i(a){return A.iv(this,"(",")")}}
A.ad.prototype={
i(a){return"MapEntry("+A.w(this.a)+": "+A.w(this.b)+")"}}
A.B.prototype={
gt(a){return A.b.prototype.gt.call(this,0)},
i(a){return"null"}}
A.b.prototype={$ib:1,
S(a,b){return this===b},
gt(a){return A.cx(this)},
i(a){return"Instance of '"+A.dQ(this)+"'"},
gu(a){return A.fG(this)},
toString(){return this.i(this)}}
A.cM.prototype={
i(a){return""},
$ia2:1}
A.cA.prototype={
gp(a){return this.a.length},
i(a){var s=this.a
return s.charCodeAt(0)==0?s:s}}
A.d7.prototype={
$2(a,b){var s=t.g
this.a.Y(new A.d5(s.a(a)),new A.d6(s.a(b)),t.X)},
$S:23}
A.d5.prototype={
$1(a){var s=this.a
return s.call(s)},
$S:33}
A.d6.prototype={
$2(a,b){var s,r,q,p
t.K.a(a)
t.l.a(b)
s=t.m
r=t.g.a(s.a(self).Error)
s=A.eU(r,["Dart exception thrown from converted Future. Use the properties 'error' to fetch the boxed error and 'stack' to recover the stack trace."],s)
if(t.e.b(a))A.an("Attempting to box non-Dart object.")
q={}
q[$.ia()]=a
s.error=q
s.stack=b.i(0)
p=this.a
p.call(p,s)},
$S:8}
A.f5.prototype={
$1(a){var s,r,q,p
if(A.hF(a))return a
s=this.a
if(s.a0(a))return s.j(0,a)
if(a instanceof A.ac){r={}
s.C(0,a,r)
for(s=a.gaf(),s=s.gB(s);s.l();){q=s.gm()
r[q]=this.$1(a.j(0,q))}return r}else if(t.bU.b(a)){p=[]
s.C(0,a,p)
B.a.bt(p,J.cU(a,this,t.z))
return p}else return a},
$S:13}
A.f8.prototype={
$1(a){return this.a.V(this.b.h("0/?").a(a))},
$S:16}
A.f9.prototype={
$1(a){if(a==null)return this.a.aR(new A.dO(a===undefined))
return this.a.aR(a)},
$S:16}
A.eX.prototype={
$1(a){var s,r,q,p,o,n,m,l,k,j,i,h
if(A.hE(a))return a
s=this.a
a.toString
if(s.a0(a))return s.j(0,a)
if(a instanceof Date){r=a.getTime()
if(r<-864e13||r>864e13)A.an(A.aE(r,-864e13,864e13,"millisecondsSinceEpoch",null))
A.eV(!0,"isUtc",t.y)
return new A.c8(r,0,!0)}if(a instanceof RegExp)throw A.d(A.a7("structured clone of RegExp",null))
if(typeof Promise!="undefined"&&a instanceof Promise)return A.hT(a,t.X)
q=Object.getPrototypeOf(a)
if(q===Object.prototype||q===null){p=t.X
o=A.fk(p,p)
s.C(0,a,o)
n=Object.keys(a)
m=[]
for(s=J.bZ(n),p=s.gB(n);p.l();)m.push(A.eW(p.gm()))
for(l=0;l<s.gp(n);++l){k=s.j(n,l)
if(!(l<m.length))return A.J(m,l)
j=m[l]
if(k!=null)o.C(0,j,this.$1(a[k]))}return o}if(a instanceof Array){i=a
o=[]
s.C(0,a,o)
h=A.a3(a.length)
for(s=J.bZ(i),l=0;l<h;++l)o.push(this.$1(s.j(i,l)))
return o}return a},
$S:13}
A.dO.prototype={
i(a){return"Promise was rejected with a value of `"+(this.a?"undefined":"null")+"`."}}
A.eI.prototype={
bN(){var s=self.crypto
if(s!=null)if(s.getRandomValues!=null)return
throw A.d(A.ef("No source of cryptographically secure random numbers available."))},
aU(a){var s,r,q,p,o,n,m,l,k=null
if(a<=0||a>4294967296)throw A.d(new A.aS(k,k,!1,k,k,"max must be in range 0 < max \u2264 2^32, was "+a))
if(a>255)if(a>65535)s=a>16777215?4:3
else s=2
else s=1
r=this.a
r.$flags&2&&A.cS(r,11)
r.setUint32(0,0,!1)
q=4-s
p=A.a3(Math.pow(256,s))
for(o=a-1,n=(a&o)===0;!0;){crypto.getRandomValues(J.ic(B.a7.gdn(r),q,s))
m=r.getUint32(0,!1)
if(n)return(m&o)>>>0
l=m%a
if(m-l+a<p)return l}}}
A.e9.prototype={
$1(a){var s
if(a===6)return this.a.aU(16)&15|64
else{s=this.a
if(a===8)return s.aU(4)&3|8
else return s.aU(256)}},
$S:46}
A.ea.prototype={
$1(a){return B.l.bw(B.f.dJ(A.a3(a),16),2,"0")},
$S:55}
A.dM.prototype={
$1(a){return A.h(a)},
$S:14}
A.d2.prototype={
S(a,b){var s=this
if(b==null)return!1
if(s===b)return!0
if(!(b instanceof A.bD))return!1
if(A.fG(b)!==A.fG(s))return!1
return A.im([s.b,s.a],[b.b,b.a],t.z)},
gt(a){return A.fU([this.b,this.a])}}
A.e0.prototype={
Z(a,b){var s=null
return this.bM(b.h("0/()").a(a),b,b)},
bM(a,b,c){var s=0,r=A.Z(c),q,p=2,o=[],n=[],m=this,l,k,j,i,h,g
var $async$Z=A.a_(function(d,e){if(d===1){o.push(e)
s=p}while(true)switch(s){case 0:i=null
h=m.a
g=new A.bO(new A.n($.o,t.U),t.b5)
m.a=g.a
p=3
s=h!=null?6:7
break
case 6:s=i!=null?8:10
break
case 8:s=11
return A.a4(h.dI(i),$async$Z)
case 11:s=9
break
case 10:s=12
return A.a4(h,$async$Z)
case 12:case 9:case 7:l=a.$0()
s=l instanceof A.n?13:15
break
case 13:j=l
s=16
return A.a4(b.h("F<0>").b(j)?j:A.fr(b.a(j),b),$async$Z)
case 16:j=e
q=j
n=[1]
s=4
break
s=14
break
case 15:q=l
n=[1]
s=4
break
case 14:n.push(5)
s=4
break
case 3:n=[2]
case 4:p=2
k=new A.e2(m,g)
if(h!=null&&i!=null)h.ah(new A.e1(k),t.P)
else k.$0()
s=n.pop()
break
case 5:case 1:return A.X(q,r)
case 2:return A.W(o.at(-1),r)}})
return A.Y($async$Z,r)}}
A.e2.prototype={
$0(){var s=this.a,r=this.b
if(s.a===r.a)s.a=null
r.aQ()},
$S:2}
A.e1.prototype={
$1(a){this.a.$0()},
$S:6}
A.bD.prototype={
i(a){return this.a}}
A.cP.prototype={}
A.dg.prototype={
$0(){return A.h(this.a.dataHex)},
$S:9}
A.df.prototype={
$0(){return B.l.bJ(A.h(this.a.dataHex),2)},
$S:9}
A.dc.prototype={
$0(){return t.K.a(this.a.data)},
$S:7}
A.dd.prototype={
$1(a){var s=t.K
s.a(a).serializeFixedBytes(s.a(this.a.data))},
$S:15}
A.de.prototype={
$0(){return A.h(this.a.dataHex)},
$S:9}
A.ar.prototype={
T(){return"JSAptosWalletStandardUserResponseStatus."+this.b}}
A.dh.prototype={
$1(a){return t.aV.a(a).c===this.a},
$S:38}
A.di.prototype={
$0(){return A.an(B.j)},
$S:4}
A.ct.prototype={}
A.ae.prototype={
bE(a,b,c,d){var s,r,q
t.K.a(a)
try{r=self
s=r.Reflect.get(a,b,d)
if(typeof s==="undefined"){r=A.jo(r.Reflect.set(a,b,c,d))
return r}return!1}catch(q){return!1}},
bD(a,b,c){var s,r,q
t.K.a(a)
s=b==null
r=!s||null
if(r===!0)if(!s&&typeof b==="string")if(B.l.bH(A.h(A.eW(b)),"is")){q=self.Reflect.get(a,b,c)
if(q!=null)return q
return!0}return self.Reflect.get(a,b,c)}}
A.d1.prototype={
$1(a){var s,r=t.m
r.a(a)
s=self
r.a(s.window).dispatchEvent(this.a)
r.a(s.window).removeEventListener("eip6963:requestProvider",A.e(this))},
$S:10}
A.dA.prototype={
$2(a,b){A.h(a)
return b==null},
$S:30}
A.dB.prototype={
$0(){return A.fl(this.a)},
$S:9}
A.ek.prototype={
$2(a,b){var s,r,q,p=t.g
p.a(a)
p.a(b)
p=this.a.Y(new A.eh(a),new A.ei(b),t.X)
s=new A.ej(b,a)
r=p.$ti
q=$.o
if(q!==B.e)s=A.hG(s,q)
p.ai(new A.ai(new A.n(q,r),2,null,s,r.h("ai<1,1>")))},
$S:23}
A.eh.prototype={
$1(a){var s=this.a
s.call(s,a)
return a},
$S:13}
A.ei.prototype={
$2(a,b){var s
t.K.a(a)
a.stack=t.l.a(b).i(0)
s=this.a
s.call(s,a)
return a},
$S:48}
A.ej.prototype={
$1(a){this.a.call(this.b,a)
return a},
$S:25}
A.dS.prototype={
$0(){return this.a.a},
$S:11}
A.dT.prototype={
$0(){return this.a.b},
$S:17}
A.dU.prototype={
$0(){var s,r,q=this.a,p=t.m,o=p.a(self),n=p.a(o.Object),m=p.a(n.create.apply(n,[null]))
m.set=A.fA(q.gaB())
m.get=A.fz(q.gaA())
n=p.a(o.Object)
s=p.a(n.create.apply(n,[null]))
s.get=A.r(new A.dS(q))
n=p.a(o.Object)
n.defineProperty.apply(n,[m,"debugKey",s])
n=p.a(o.Object)
r=p.a(n.create.apply(n,[null]))
r.get=A.r(new A.dT(q))
o=p.a(o.Object)
o.defineProperty.apply(o,[m,"object",r])
return m},
$S:7}
A.dR.prototype={
$1(a){return A.h(a)},
$S:14}
A.f6.prototype={
$1(a){var s,r,q,p=this,o=t.m
o.a(a)
s=p.a
if(s.a)return
r=o.a(o.a(a.detail).data)
if(A.h1(A.h(r.status))===B.G){q=A.h0(A.hi(r))
if(A.ak(q.message)!=null)o.a(self.console).error(A.ak(q.message))
o=p.b.d
if(o!=null)o.aR(q)
return}s.a=!0
o.a(self.window).addEventListener("WALLET_ACTIVATION",A.e(p))
o=r.data
p.b.dw(A.h(o==null?null:A.eW(o)))},
$S:10}
A.as.prototype={
T(){return"JSWalletMessageType."+this.b}}
A.dC.prototype={
$1(a){return t.cP.a(a).b===this.a},
$S:31}
A.dD.prototype={
$0(){return A.an(B.j)},
$S:4}
A.L.prototype={
T(){return"JSNetworkEventType."+this.b}}
A.dr.prototype={
$1(a){return t.cA.a(a).b===this.a},
$S:32}
A.ds.prototype={
$0(){return A.an(B.j)},
$S:4}
A.U.prototype={
T(){return"JSEventType."+this.b}}
A.dp.prototype={
$1(a){return t.G.a(a).b===this.a},
$S:26}
A.dq.prototype={
$0(){return A.an(B.j)},
$S:4}
A.dn.prototype={
$1(a){return t.G.a(a).b===this.a},
$S:26}
A.at.prototype={
T(){return"JSWalletResponseType."+this.b}}
A.dH.prototype={
$1(a){return t.c9.a(a).b===this.a},
$S:34}
A.dI.prototype={
$0(){return A.an(B.j)},
$S:4}
A.D.prototype={
T(){return"JSClientType."+this.b}}
A.dl.prototype={
$1(a){return t.D.a(a).b===this.a},
$S:35}
A.dm.prototype={
$0(){return A.an(B.j)},
$S:4}
A.cv.prototype={
T(){return"PageRequestType."+this.b}}
A.eg.prototype={
$2(a,b){if(b instanceof A.ac)this.a.C(0,a,A.hh(this.b,b))},
$S:29}
A.dj.prototype={
gI(){var s=this.a
if(s===$){s!==$&&A.c1("requestController")
s=this.a=new A.cu(this.gbx(),A.fk(t.N,t.p))}return s},
gbs(){var s,r,q=this,p=q.b
if(p===$){s=q.gI()
r=A.a([],t.I)
q.b!==$&&A.c1("_walletStandardController")
p=q.b=new A.bh(s,{},{},r)}return p},
ar(){var s=0,r=A.Z(t.H),q,p=this,o
var $async$ar=A.a_(function(a,b){if(a===1)return A.W(b,r)
while(true)switch(s){case 0:o=p.c
o=o==null?null:o.Z(new A.dk(p),t.H)
s=3
return A.a4(o instanceof A.n?o:A.fr(o,t.H),$async$ar)
case 3:q=b
s=1
break
case 1:return A.X(q,r)}})
return A.Y($async$ar,r)},
gbj(){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c,b,a,a0,a1,a2=this,a3=a2.e
if(a3===$){s=a2.gI()
r=t.I
q=t.G
p=t.u
o=A.C([B.b,A.a([],r),B.c,A.a([],r),B.i,A.a([],r),B.q,A.a([],r),B.k,A.a([],r)],q,p)
n=A.C([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
m=a2.gI()
l={base58:!1,hex:!1}
k=A.C([B.b,A.a([],r),B.c,A.a([],r),B.i,A.a([],r),B.k,A.a([],r)],q,p)
j=A.C([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
i=a2.gI()
h=A.C([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
g=a2.gI()
f=A.C([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
e=a2.gI()
d=A.C([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
c=a2.gI()
b=A.C([B.b,A.a([],r)],q,p)
a=A.C([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)
a0=a2.gI()
a1=A.C([B.x,new A.bc(o,s,n),B.D,new A.bA(l,k,m,j),B.y,new A.bu(i,h),B.C,new A.bz(g,f),B.z,new A.bw(e,d),B.A,new A.bx(b,c,a),B.u,new A.b5(A.C([B.b,A.a([],r),B.c,A.a([],r)],q,p),a0,A.C([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)),B.B,new A.by(a2.gI(),A.C([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)),B.w,new A.ba(a2.gI(),A.C([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p)),B.v,new A.b8(a2.gI(),A.C([B.b,A.a([],r),B.c,A.a([],r),B.d,A.a([],r)],q,p))],t.D,t.d5)
a2.e!==$&&A.c1("_networks")
a2.sbP(a1)
a3=a1}return a3},
ck(){var s,r,q,p,o,n,m,l,k,j,i,h=this
try{for(p=h.gbj(),p=new A.bi(p,A.H(p).h("bi<1,2>")).gB(0),o=t.I,n=h.gbx(),m=t.N,l=t.p;p.l();){k=p.d
k.toString
s=k
r=s.b
j=h.b
if(j===$){j=h.a
if(j===$){j!==$&&A.c1("requestController")
j=h.a=new A.cu(n,A.fk(m,l))}k=A.a([],o)
h.b!==$&&A.c1("_walletStandardController")
j=h.b=new A.bh(j,{},{},k)}r.N(j.c)}h.gbs().aK()}catch(i){q=A.ao(i)
p=self
t.m.a(p.console).error("Initializing wallet failed: "+A.w(q))}},
dv(a){var s,r,q,p,o,n=t.m
if(A.iF(A.h(n.a(a.data).type))===B.M){s=this.gI().b.j(0,A.h(a.requestId))
if(s!=null){n=n.a(a.data)
s.b.V(n)}return}r=n.a(a.data)
if((A.ak(a.client)==null?null:A.fY(A.ak(a.client)))==null){s=this.gbs()
r=n.a(r.data)
q=t.r
if(q.a(r.accounts)!=null){p=q.a(r.accounts)
p.toString
s.b.accounts=p}if(q.a(r.chains)!=null){p=q.a(r.chains)
p.toString
s.b.chains=p}o={}
o.change=A.O(r,n)
o.accounts=q.a(r.accounts)
o.chains=q.a(r.chains)
s.cc(A.O(o,n))
return}n=this.gbj()
n=n.j(0,A.ak(a.client)==null?null:A.fY(A.ak(a.client)))
if(n!=null)n.ag(r)},
sbP(a){this.e=t.co.a(a)}}
A.dk.prototype={
$0(){var s=0,r=A.Z(t.H),q,p=2,o=[],n=[],m=this,l
var $async$$0=A.a_(function(a,b){if(a===1){o.push(b)
s=p}while(true)switch(s){case 0:p=3
l=m.a.d
l=l==null?null:l.a
s=6
return A.a4(l instanceof A.n?l:A.fr(l,t.H),$async$$0)
case 6:l=b
q=l
n=[1]
s=4
break
n.push(5)
s=4
break
case 3:n=[2]
case 4:p=2
l=m.a
l.c=l.d=null
s=n.pop()
break
case 5:case 1:return A.X(q,r)
case 2:return A.W(o.at(-1),r)}})
return A.Y($async$$0,r)},
$S:36}
A.ch.prototype={
az(a){var s=0,r=A.Z(t.H),q=this,p,o,n
var $async$az=A.a_(function(b,c){if(b===1)return A.W(c,r)
while(true)switch(s){case 0:s=2
return A.a4(q.ar(),$async$az)
case 2:p=q.f
o=self
n=t.m
p=n.a(new o.CustomEvent(p,{bubbles:!0,cancelable:!1,detail:a,data:null}))
n.a(o.window).dispatchEvent(p)
return A.X(null,r)}})
return A.Y($async$az,r)},
cD(a){var s=t.m
this.dv(s.a(s.a(a).detail))},
dw(a){var s,r=this
if(r.f!=null)return
r.f="WALLET_"+a
t.m.a(self.window).addEventListener("ETH_"+a,A.e(r.gcC()))
s=r.d
if(s!=null)s.aQ()}}
A.bh.prototype={
aN(a,b){var s
A.h(a)
t.g.a(b)
s=A.be(a)
if(s!==B.d)return null
if(s!=null)B.a.q(this.d,b)
this.a.a.$1(A.h5(null,A.aQ(B.d)))
return A.r(new A.dw(this,b))},
cc(a){var s,r,q,p=A.ab(this.d,!0,t.g)
for(s=p.length,r=0;r<s;++r){q=p[r]
q.call(q,a)}},
a6(a){return A.R(new A.dt(this,t.A.a(a)).$0(),t.m)},
A(){return this.a6(null)},
aK(){var s,r,q,p=this,o=p.c
o["standard:events"]=A.a1(A.v(p.gH()))
s={}
s.connect=A.e(p.gv())
s.version="1.0.0"
o["standard:connect"]=s
r=p.b
r.features=o
r.name="MRT"
r.version="1.0.0"
r.icon=u.f
r.accounts=A.a([],t.O)
r=self
o=t.m
q=o.a(new r.CustomEvent("wallet-standard:register-wallet",{bubbles:!1,cancelable:!1,detail:A.e(new A.du(p))}))
o.a(r.window).addEventListener("wallet-standard:app-ready",A.e(new A.dv(q)))
o.a(r.window).dispatchEvent(q)}}
A.dw.prototype={
$0(){B.a.X(this.a.d,this.b)},
$S:2}
A.dt.prototype={
$0(){var s=0,r=A.Z(t.m),q,p=this,o,n,m
var $async$$0=A.a_(function(a,b){if(a===1)return A.W(b,r)
while(true)switch(s){case 0:m=p.b
if(m!=null){m=A.ax(m.silent)
o=m===!0}else o=!1
m=p.a
s=3
return A.a4(m.a.L("connect",A.a([o],t.bx),t.m),$async$$0)
case 3:n=b
m.b.accounts=t.c.a(n.accounts)
q=n
s=1
break
case 1:return A.X(q,r)}})
return A.Y($async$$0,r)},
$S:39}
A.du.prototype={
$1(a){t.K.a(a).register(this.a.b)},
$S:15}
A.dv.prototype={
$1(a){t.K.a(a)
t.m.a(self.window).dispatchEvent(this.a)},
$S:15}
A.E.prototype={
R(a,b,c,d){return this.a.bC(this.gD(),a,b,c,d)},
k(a,b,c){return this.R(a,b,B.m,c)},
M(a,b){return this.R(a,null,B.m,b)},
bB(a,b,c){return this.R(a,null,b,c)},
L(a,b,c){return this.dN(a,b,c,c)},
bA(a,b){return this.L(a,null,b)},
dN(a,b,c,d){var s=0,r=A.Z(d),q,p=this
var $async$L=A.a_(function(e,f){if(e===1)return A.W(f,r)
while(true)switch(s){case 0:q=p.a.a1(p.gD(),a,b,B.m,c)
s=1
break
case 1:return A.X(q,r)}})
return A.Y($async$L,r)},
cb(){return this.a.dO(this.gD(),"disconnect",t.X)},
a_(a){var s=A.iC(A.h(a.event))
if(!(s===B.b||s===B.c||s===B.i||s===B.d))return
this.a.a.$1(A.h5(this.gD(),a))},
aN(a,b){var s,r
A.h(a)
t.g.a(b)
s=A.be(a)
if(s!=null){r=this.b.j(0,s)
r.toString
B.a.q(r,b)
this.a_(A.aQ(s))}},
al(a,b){var s,r,q,p=A.ab(t.u.a(a),!0,t.g)
for(s=p.length,r=0;r<s;++r){q=p[r]
q.call(q,b)}},
cf(a,b){var s=this.b
if(!s.a0(a))return
s=s.j(0,a)
s.toString
this.al(s,b)},
ag(a){var s,r,q,p=t.m.a(a.data),o=A.dE(p)
for(s=o.length,r=t.A,q=0;q<o.length;o.length===s||(0,A.c0)(o),++q)switch(o[q]){case B.L:this.cf(B.d,r.a(p.change))
break}}}
A.cu.prototype={
an(a,b){return this.cj(a,b)},
cj(a,b){var s=0,r=A.Z(t.m),q,p=2,o=[],n=[],m=this,l,k,j,i
var $async$an=A.a_(function(c,d){if(c===1){o.push(d)
s=p}while(true)switch(s){case 0:i=new A.ct(A.j2(),new A.ah(new A.n($.o,t.aX),t.x))
p=3
k=i.a
j=a==null?null:a.b
l={data:b,requestId:k,client:j}
m.a.$1(l)
j=m.b
k=i.a
if(j.j(0,k)==null)j.C(0,k,i)
s=6
return A.a4(i.b.a,$async$an)
case 6:k=d
q=k
n=[1]
s=4
break
n.push(5)
s=4
break
case 3:n=[2]
case 4:p=2
m.b.X(0,i.a)
s=n.pop()
break
case 5:case 1:return A.X(q,r)
case 2:return A.W(o.at(-1),r)}})
return A.Y($async$an,r)},
bC(a,b,c,d,e){return A.R(this.a1(a,b,c,d,e),e)},
dO(a,b,c){return this.bC(a,b,null,B.m,c)},
a1(a,b,c,d,e){return this.dM(a,b,c,d,e,e)},
L(a,b,c){return this.a1(null,a,b,B.m,c)},
dM(a,b,c,d,e,f){var s=0,r=A.Z(f),q,p=this,o
var $async$a1=A.a_(function(g,h){if(g===1)return A.W(h,r)
while(true)$async$outer:switch(s){case 0:s=3
return A.a4(p.an(a,{type:"request",method:b,params:c,providerType:d.b}),$async$a1)
case 3:o=h
switch(A.h1(A.h(o.status))){case B.N:q=e.a(o.data)
s=1
break $async$outer
case B.G:throw A.d(A.h0(A.hi(o)))}case 1:return A.X(q,r)}})
return A.Y($async$a1,r)}}
A.b5.prototype={
c2(a){var s=t.K
return this.k("wallet_switchAptosChain",A.a([s.a(a)],t.f),s)},
F(a){var s=t.K
return A.R(this.L("aptos_signMessage",A.a([s.a(a)],t.f),s).ah(new A.cW(),s),s)},
K(a){var s=t.K
return A.R(this.L("aptos_signTransaction",A.a([A.iz(s.a(a))],t.f),s).ah(new A.cX(),s),s)},
cP(){var s=t.K
return A.R(this.bA("aptos_requestAccounts",s).ah(new A.cV(),s),s)},
cv(){return this.M("aptos_network",t.K)},
cz(a){var s
t.g.a(a)
s=this.c.j(0,B.b)
s.toString
B.a.q(s,a)
this.a_(A.aQ(B.b))},
cB(a){var s
t.g.a(a)
s=this.c.j(0,B.c)
s.toString
B.a.q(s,a)
this.a_(A.aQ(B.c))},
al(a,b){var s,r,q=A.ab(t.u.a(a),!0,t.g)
for(s=q.length,r=0;r<s;++r)q[r].call(null,b)},
ag(a){var s,r,q,p,o,n,m,l,k=this
k.aC(a)
s=t.m.a(a.data)
r=A.dE(s)
for(q=r.length,p=k.c,o=t.A,n=0;n<r.length;r.length===q||(0,A.c0)(r),++n)switch(r[n]){case B.t:m=p.j(0,B.b)
m.toString
k.al(m,o.a(s.account))
break
case B.r:l=s.chainChanged
if(l!=null){m=p.j(0,B.c)
m.toString
k.al(m,l)}break}},
gD(){return B.u},
N(a){var s=this,r=s.gcO(),q={}
q.connect=A.r(r)
q.version="1.0.0"
a["aptos:connect"]=q
q={}
q.signTransaction=A.e(s.gJ())
q.version="1.0.0"
a["aptos:signTransaction"]=q
q={}
q.signMessage=A.e(s.gE())
q.version="1.0.0"
a["aptos:signMessage"]=q
q={}
q.account=A.r(r)
q.version="1.0.0"
a["aptos:account"]=q
q={}
q.onNetworkChange=A.e(s.gcA())
q.version="1.0.0"
a["aptos:onNetworkChange"]=q
q={}
q.network=A.r(s.gcu())
q.version="1.0.0"
a["aptos:network"]=q
q={}
q.onAccountChange=A.e(s.gcw())
q.version="1.0.0"
a["aptos:onAccountChange"]=q
q={}
q.disconnect=A.r(s.ga7())
q.version="1.0.0"
a["aptos:disconnect"]=q
q={}
q.changeNetwork=A.e(s.gc1())
q.version="1.0.0"
a["aptos:changeNetwork"]=q
a["aptos:events"]=A.a1(A.v(s.gH()))}}
A.cW.prototype={
$1(a){var s,r=t.K
r.a(a)
if(A.fg(A.h(a.status))===B.p)return a
s=r.a(a.args)
A.ff(s)
return A.fh(s,r)},
$S:20}
A.cX.prototype={
$1(a){var s,r=t.K
r.a(a)
if(A.fg(A.h(a.status))===B.p)return a
s=r.a(a.args)
A.ff(s)
return A.fh(s,r)},
$S:20}
A.cV.prototype={
$1(a){var s,r,q=t.K
q.a(a)
if(A.fg(A.h(a.status))===B.p)return a
s=t.m
r=s.a(q.a(a.args))
A.ff(s.a(r.publicKey))
r.publicKey=A.O(s.a(r.publicKey),s)
return A.fh(r,s)},
$S:20}
A.b8.prototype={
N(a){var s=this,r={}
r.connect=A.r(s.gv())
r.version="1.0.0"
a["bitcoin:connect"]=r
r={}
r.signPersonalMessage=A.e(s.gbY())
r.version="1.0.0"
a["bitcoin:signPersonalMessage"]=r
r={}
r.signTransaction=A.e(s.gc_())
r.version="1.0.0"
a["bitcoin:signTransaction"]=r
r={}
r.sendTransaction=A.e(s.gbW())
r.version="1.0.0"
a["bitcoin:sendTransaction"]=r
r={}
r.disconnect=A.r(s.ga7())
r.version="1.0.0"
a["bitcoin:disconnect"]=r
a["bitcoin:events"]=A.a1(A.v(s.gH()))},
A(){return this.M("bitcoin_requestAccounts",t.m)},
bZ(a){var s=t.K
return this.k("bitcoin_signPersonalMessage",A.a([s.a(a)],t.f),s)},
c0(a){var s=t.K
return this.k("bitcoin_signTransaction",A.a([s.a(a)],t.f),s)},
bX(a){var s=t.K
return this.k("bitcoin_sendTransaction",A.a([s.a(a)],t.f),s)},
gD(){return B.v}}
A.ba.prototype={
dr(){return this.M("cosmos_requestAccounts",t.m)},
F(a){var s=t.K
return this.k("cosmos_signMessage",A.a([s.a(a)],t.f),s)},
bb(a,b){var s,r,q
A.h(a)
s=A.r(new A.d_(this,a))
r=A.v(new A.d0(this,a,b))
q={}
q.getAccounts=s
q.signDirect=r
return A.O(q,t.K)},
ba(a){return this.bb(a,null)},
bf(a,b){var s,r,q
A.h(a)
s=A.r(new A.cY(this,a))
r=A.v(new A.cZ(this,a,b))
q={}
q.getAccounts=s
q.signAmino=r
return A.O(q,t.K)},
be(a){return this.bf(a,null)},
bp(a,b){var s,r
A.h(a)
s=this.ba(a)
r={}
r.amino=this.be(a)
r.direct=s
return A.O(r,t.K)},
dl(a){return this.bp(a,null)},
ci(a){A.h(a)
throw A.d(A.fq(null))},
gD(){return B.w},
aE(a){return this.k("cosmos_addNewChain",A.a([t.K.a(a)],t.f),t.y)},
K(a){var s=t.K
return this.k("cosmos_signTransaction",A.a([s.a(a)],t.f),s)},
N(a){var s,r,q=this
if(q.c==null){s={}
s.getOfflineSigner=A.v(q.gb9())
s.getOfflineSignerOnlyAmino=A.v(q.gbd())
s.getOfflineSignerAuto=A.e(q.gbc())
r=A.O(s,t.m)
q.c=s
q.d=r}r=self
r.keplr=q.d
r.getOfflineSigner=A.v(q.gb9())
r.getOfflineSignerOnlyAmino=A.v(q.gbd())
r.getOfflineSignerAuto=A.e(q.gbc())
s={}
s.connect=A.r(q.gdq())
s.version="1.0.0"
a["cosmos:connect"]=s
a["cosmos:events"]=A.a1(A.v(q.gH()))
s={}
s.signer=A.v(q.gdk())
s.version="1.0.0"
a["cosmos:signer"]=s
s={}
s.addNewChain=A.e(q.gaD())
s.version="1.0.0"
a["cosmos:addNewChain"]=s
s={}
s.signMessage=A.e(q.gE())
s.version="1.0.0"
a["cosmos:signMessage"]=s
s={}
s.signTransaction=A.e(q.gJ())
s.version="1.0.0"
a["cosmos:signTransaction"]=s}}
A.d_.prototype={
$0(){return this.a.k("cosmos_requestAccounts",A.h9(A.a([this.b],t.s)),t.c)},
$S:3}
A.d0.prototype={
$2(a,b){var s,r
A.h(a)
s=t.K
r={}
r.signDoc=s.a(b)
r.signerAddress=a
r.chainId=this.b
r.signOption=this.c
return this.a.k("cosmos_signTransactionDirect",A.a([r],t.f),s)},
$S:28}
A.cY.prototype={
$0(){return this.a.k("cosmos_requestAccounts",A.h9(A.a([this.b],t.s)),t.c)},
$S:3}
A.cZ.prototype={
$2(a,b){var s,r
A.h(a)
s=t.K
s.a(b)
r={}
r.signDoc=A.h(t.m.a(self.JSON).stringify(b))
r.signerAddress=a
r.chainId=this.b
r.signOption=this.c
return this.a.k("cosmos_signTransactionAmino",A.a([r],t.f),s)},
$S:28}
A.bc.prototype={
aO(a){t.m.a(a)
return this.R(A.h(a.method),t.r.a(a.params),B.h,t.X)},
c5(){return this.bB("eth_requestAccounts",B.h,t.c)},
A(){return this.M("eth_requestAccounts",t.m)},
aE(a){return this.k("wallet_addEthereumChain",A.a([t.m.a(a)],t.O),t.N)},
df(a){var s=t.m
return this.k("eth_signTypedData",A.a([s.a(a)],t.O),s)},
dh(a){var s=t.m
return this.k("eth_signTypedData_v3",A.a([s.a(a)],t.O),s)},
dj(a){var s=t.m
return this.k("eth_signTypedData_v4",A.a([s.a(a)],t.O),s)},
cF(a){var s=t.m
return this.k("personal_sign",A.a([s.a(a)],t.O),s)},
ac(a){var s=t.m
return this.k("eth_sendTransaction",A.a([s.a(a)],t.O),s)},
N(a){var s,r,q,p,o,n,m=this,l=m.c
if(l==null){l=A.r(m.gc4())
s=A.e(m.gao())
r=A.v(m.gbR())
q=A.v(m.gcI())
p=A.r(m.ga7())
o={}
o.request=s
o.on=r
o.removeListener=q
o.disconnect=p
o.enable=l
o.connect=l
m.c=o
l=o}n=A.O(l,t.m)
self.ethereum=n
A.ip(n)
o={}
o.connect=A.r(m.gv())
o.version="1.0.0"
a["ethereum:connect"]=o
o={}
o.addNewChain=A.e(m.gaD())
o.version="1.0.0"
a["ethereum:addNewChain"]=o
o={}
o.signTypedData=A.e(m.gde())
o.version="1.0.0"
a["ethereum:signTypedData"]=o
o={}
o.signTypedDataV3=A.e(m.gdg())
o.version="1.0.0"
a["ethereum:signTypedDataV3"]=o
o={}
o.signTypedDataV4=A.e(m.gdi())
o.version="1.0.0"
a["ethereum:signTypedDataV4"]=o
o={}
o.personalSign=A.e(m.gcE())
o.version="1.0.0"
a["ethereum:personalSign"]=o
o={}
o.sendTransaction=A.e(m.gab())
o.version="1.0.0"
a["ethereum:sendTransaction"]=o
o={}
o.request=A.e(m.gao())
o.version="1.0.0"
a["ethereum:request"]=o
a["ethereum:events"]=A.a1(A.v(m.gH()))},
ag(a){var s,r,q,p,o,n,m,l,k=this,j=null
k.aC(a)
s=t.m.a(a.data)
r=A.dE(s)
for(q=r.length,p=t.A,o=0;o<r.length;r.length===q||(0,A.c0)(r),++o)switch(r[o]){case B.t:n=k.c
if(n!=null){m=p.a(s.account)
m=m==null?j:A.h(m.address)
n.selectedAddress=m}break
case B.F:k.a8(B.q,s.message)
break
case B.E:n=p.a(s.networkAccounts)
k.a8(B.b,n==null?j:A.h_(n))
break
case B.r:l=p.a(s.chainChanged)
n=k.c
if(n!=null){m=l==null?j:A.h(l.chainId)
n.chainId=m}n=k.c
if(n!=null){m=l==null?j:A.h(l.netVersion)
n.networkVersion=m}if(s.disconnect!=null)k.a8(B.k,s.disconnect)
if(l!=null){if(s.disconnect==null)k.a8(B.i,l)
k.a8(B.c,A.h(l.chainId))}break}},
a8(a,b){var s,r,q
if(b==null||!this.d.a0(a))return
s=this.d.j(0,a)
s.toString
s=A.ab(s,!0,t.g)
for(r=s.length,q=0;q<r;++q)s[q].call(null,b)},
bS(a,b){var s,r
A.h(a)
t.g.a(b)
s=A.be(a)
if(s==null)return
r=this.d.j(0,s)
if(r!=null)B.a.q(r,b)
this.a_(A.aQ(s))},
cJ(a,b){var s
A.h(a)
t.g.a(b)
s=this.d.j(0,A.be(a))
if(s!=null)B.a.X(s,b)},
gD(){return B.x}}
A.bu.prototype={
N(a){var s=this,r=A.e(s.gcZ()),q=A.e(s.gd6()),p=A.e(s.gE()),o=$.hZ(),n={}
n.signTransaction=q
n.version="1.0.0"
n.supportedTransactionVersions=o
a["solana:signTransaction"]=n
n={}
n.signAndSendTransaction=r
n.version="1.0.0"
n.supportedTransactionVersions=o
a["solana:signAndSendTransaction"]=n
n={}
n.signMessage=p
n.version="1.0.0"
a["solana:signMessage"]=n
n={}
n.signAndSendAllTransactions=A.v(s.gcX())
n.version="1.0.0"
n.supportedTransactionVersions=o
a["solana:signAndSendAllTransactions"]=n
a["solana:events"]=A.a1(A.v(s.gH()))
n={}
n.connect=A.r(s.gv())
n.version="1.0.0"
a["solana:connect"]=n
n={}
n.signIn=A.e(s.gd0())
n.version="1.0.0"
a["solana:signIn"]=n},
A(){return this.M("solana_requestAccounts",t.m)},
d1(a){var s=t.m
return A.R(this.L("solana_signIn",A.dJ(s.a(a)),s),s)},
F(a){var s=t.c
return A.R(this.L("solana_signMessage",A.dJ(t.m.a(a)),s),s)},
d7(a){var s=t.c
return A.R(this.L("solana_signTransaction",A.dJ(t.K.a(a)),s),s)},
d_(a){return this.k("solana_signAndSendTransaction",A.dJ(t.m.a(a)),t.c)},
bm(a,b){var s,r=t.c
r.a(a)
t.A.a(b)
s=A.a([a],t.f)
if(b!=null)s.push(b)
return this.k("solana_signAndSendAllTransactions",s,r)},
cY(a){return this.bm(a,null)},
gD(){return B.y}}
A.bw.prototype={
N(a){var s=this,r={}
r.signAndSendTransaction=A.e(s.gab())
r.version="1.0.0"
a["stellar:signAndSendTransaction"]=r
r={}
r.signTransaction=A.e(s.gJ())
r.version="1.0.0"
a["stellar:signTransaction"]=r
r={}
r.signMessage=A.e(s.gE())
r.version="1.0.0"
a["stellar:signMessage"]=r
r={}
r.connect=A.r(s.gv())
r.version="1.0.0"
a["stellar:connect"]=r
a["stellar:events"]=A.a1(A.v(s.gH()))},
A(){return this.M("stellar_requestAccounts",t.m)},
K(a){var s=t.K
return this.k("stellar_signTransaction",A.a([s.a(a)],t.f),s)},
ac(a){var s=t.K
return this.k("stellar_sendTransaction",A.a([s.a(a)],t.f),s)},
F(a){return this.k("stellar_signMessage",A.a([t.m.a(a)],t.O),t.K)},
gD(){return B.z}}
A.bx.prototype={
N(a){var s,r=this
r.cl()
s={}
s.signTransaction=A.e(r.gaY())
s.version="1.0.0"
a["substrate:signTransaction"]=s
s={}
s.signMessage=A.e(r.gaX())
s.version="1.0.0"
a["substrate:signMessage"]=s
s={}
s.connect=A.e(r.gv())
s.version="1.0.0"
a["substrate:connect"]=s
a["substrate:events"]=A.a1(A.v(r.gH()))},
cl(){var s,r,q,p,o,n=this
if(n.d==null){s={}
r={}
q={}
p={}
q.signPayload=A.e(n.gaY())
q.signRaw=A.e(n.gaX())
q.update=A.e(n.gdK())
s.get=A.e(n.gcm())
s.provide=A.e(n.gcq())
r.get=A.e(n.gc6())
r.subscribe=A.e(n.gco())
o=t.m
p.metadata=A.O(s,o)
p.accounts=A.O(r,o)
p.signer=A.O(q,o)
o=n.gaH()
p.connect=A.e(o)
p.enable=A.e(o)
p.name="MRT"
p.version="0.4.0"
n.sdm(new A.ae(null,p,t.o))}if(n.e==null)n.scG(A.eU(self.Proxy,[n.d.b,new A.e_(n).$0()],t.m))
o=self
if(t.A.a(o.injectedWeb3)==null)o.injectedWeb3={}
t.m.a(o.injectedWeb3)["0"]=n.e
o.substrate=n.e},
bg(a){A.ax(a)
return this.M("substrate_knownMetadata",t.m)},
cn(){return this.bg(null)},
cr(a){return this.k("wallet_addSubstrateChain",A.a([t.m.a(a)],t.O),t.y)},
bG(a){var s=t.m
return this.k("substrate_signTransaction",A.a([s.a(a)],t.O),s)},
bF(a){var s=t.m
return this.k("substrate_signMessage",A.a([s.a(a)],t.O),s)},
a6(a){return this.M("substrate_requestAccounts",t.m)},
A(){return this.a6(null)},
b6(a){var s=t.c
return A.R(this.bA("substrate_requestAccounts",t.m).ah(new A.dW(),s),s)},
c7(){return this.b6(null)},
bz(a){throw A.d($.fL())},
dL(){return this.bz(null)},
ce(a){A.h(a)
return A.R(new A.dX(this).$0(),t.A)},
cp(a){var s
t.g.a(a)
s=this.c.j(0,B.b)
s.toString
B.a.q(s,a)
this.a_(A.aQ(B.b))},
gD(){return B.A},
sdm(a){this.d=t.cZ.a(a)},
scG(a){this.e=t.A.a(a)}}
A.dY.prototype={
$0(){return this.a.a},
$S:11}
A.dZ.prototype={
$0(){return this.a.b},
$S:17}
A.e_.prototype={
$0(){var s,r,q,p,o,n,m=this.a.d
m.toString
s=t.m
r=s.a(self)
q=s.a(r.Object)
p=s.a(q.create.apply(q,[null]))
p.set=A.fA(m.gaB())
p.get=A.fz(m.gaA())
q=s.a(r.Object)
o=s.a(q.create.apply(q,[null]))
o.get=A.r(new A.dY(m))
q=s.a(r.Object)
q.defineProperty.apply(q,[p,"debugKey",o])
q=s.a(r.Object)
n=s.a(q.create.apply(q,[null]))
n.get=A.r(new A.dZ(m))
r=s.a(r.Object)
r.defineProperty.apply(r,[p,"object",n])
return p},
$S:7}
A.dW.prototype={
$1(a){return t.c.a(t.m.a(a).accounts)},
$S:52}
A.dX.prototype={
$0(){var s=0,r=A.Z(t.A),q,p=this
var $async$$0=A.a_(function(a,b){if(a===1)return A.W(b,r)
while(true)switch(s){case 0:q=p.a.e
s=1
break
case 1:return A.X(q,r)}})
return A.Y($async$$0,r)},
$S:53}
A.by.prototype={
F(a){var s=t.K
return this.k("sui_signMessage",A.a([s.a(a)],t.f),s)},
d5(a){var s=t.K
return this.k("sui_signPersonalMessage",A.a([s.a(a)],t.f),s)},
U(a,b,c){A.k6(c,t.K,"T","_signTransction_")
return this.dd(a,b,c,c)},
dd(a,b,c,d){var s=0,r=A.Z(d),q,p=this,o,n
var $async$U=A.a_(function(e,f){if(e===1)return A.W(f,r)
while(true)switch(s){case 0:o=a
n=A
s=3
return A.a4(A.dx(b),$async$U)
case 3:q=p.L(o,n.a([f],t.f),c)
s=1
break
case 1:return A.X(q,r)}})
return A.Y($async$U,r)},
K(a){var s=t.K
return A.R(this.U("sui_signTransaction",s.a(a),s),s)},
cW(a){var s=t.K
return A.R(this.U("sui_signAndExecuteTransaction",s.a(a),s),s)},
cU(a){var s=t.K
return A.R(this.U("sui_signAndExecuteTransactionBlock",s.a(a),s),s)},
d9(a){var s=t.K
return A.R(this.U("sui_signTransactionBlock",s.a(a),s),s)},
cN(a){t.K.a(a)
return A.is(A.it(B.I,t.z))},
gD(){return B.B},
A(){return this.M("sui_requestAccounts",t.m)},
N(a){var s=this,r={}
r.signTransaction=A.e(s.gJ())
r.version="1.0.0"
a["sui:signTransaction"]=r
r={}
r.connect=A.r(s.gv())
r.version="1.0.0"
a["sui:connect"]=r
r={}
r.signTransactionBlock=A.e(s.gd8())
r.version="1.0.0"
a["sui:signTransactionBlock"]=r
r={}
r.signAndExecuteTransactionBlock=A.e(s.gcT())
r.version="1.0.0"
a["sui:signAndExecuteTransactionBlock"]=r
r={}
r.signAndExecuteTransaction=A.e(s.gcV())
r.version="2.0.0"
a["sui:signAndExecuteTransaction"]=r
r={}
r.signPersonalMessage=A.e(s.gd4())
r.version="1.0.0"
a["sui:signPersonalMessage"]=r
r={}
r.signMessage=A.e(s.gE())
r.version="1.0.0"
a["sui:signMessage"]=r
r={}
r.reportTransactionEffects=A.e(s.gcM())
r.version="1.0.0"
a["sui:reportTransactionEffects"]=r
r={}
r.disconnect=A.r(s.ga7())
r.version="1.0.0"
a["sui:disconnect"]=r
a["sui:events"]=A.a1(A.v(s.gH()))}}
A.bz.prototype={
N(a){var s=this,r={}
r.signAndSendTransaction=A.e(s.gab())
r.version="1.0.0"
a["ton:signAndSendTransaction"]=r
r={}
r.signTransaction=A.e(s.gJ())
r.version="1.0.0"
a["ton:signTransaction"]=r
r={}
r.signMessage=A.e(s.gE())
r.version="1.0.0"
a["ton:signMessage"]=r
r={}
r.connect=A.r(s.gv())
r.version="1.0.0"
a["ton:connect"]=r
a["ton:events"]=A.a1(A.v(s.gH()))},
A(){return this.M("ton_requestAccounts",t.m)},
K(a){return this.k("ton_signTransaction",A.a([t.m.a(a)],t.O),t.K)},
ac(a){return this.k("ton_sendTransaction",A.a([t.m.a(a)],t.O),t.K)},
F(a){return this.k("ton_signMessage",A.a([t.m.a(a)],t.O),t.K)},
gD(){return B.C}}
A.bA.prototype={
aK(){var s,r,q,p,o,n,m,l,k=this,j=self,i=new j.TronWeb("https://api.shasta.trongrid.io","https://api.shasta.trongrid.io","https://api.shasta.trongrid.io"),h=k.e,g=t.m,f=A.eU(j.Proxy,[h,new A.e6(new A.ae(null,h,t.o)).$0()],g)
g.a(i.trx).sign=A.v(k.gda())
g.a(i.trx).signMessageV2=A.v(k.gd2())
g.a(i.trx).multiSign=A.v(k.gcs())
h=k.gc9()
i.setPrivateKey=A.e(h)
i.setAddress=A.e(h)
i.setFullNode=A.e(h)
i.setSolidityNode=A.e(h)
i.setHeader=A.e(h)
i.setFullNodeHeader=A.e(h)
i.setDefaultBlock=A.e(h)
i.defaultPrivateKey=""
i.defaultAddress=f
h=t.K
s=A.O(i,h)
r=A.e(k.gao())
q=A.v(k.gbT())
p=A.r(k.gaH())
o=A.v(k.gcK())
A.r(k.ga7())
n={}
n.dappIcon=""
n.dappName=""
n.openTronLinkAppOnMobile=!0
n.openUrlWhenWalletNotFound=!0
m={}
m.config=n
m.request=r
m.on=q
m.removeListener=o
m.tronWeb=s
m.enable=p
m.connect=p
m.ready=!0
l=g.a(j.Object.freeze(m))
j.tronLink=A.O(l,g)
j.tronWeb=A.O(i,h)
j.tron=A.O(l,g)
k.c=l
k.d=i},
ca(a){throw A.d($.fL())},
bn(a,b){t.K.a(a)
if(b!=null)A.fv(b)
return this.R("tron_signMessageV2",A.a([a],t.f),B.h,t.N)},
d3(a){return this.bn(a,null)},
bo(a,b){t.K.a(a)
if(b!=null)A.fv(b)
return this.R("tron_signTransaction",A.a([a],t.f),B.h,t.m)},
dc(a){return this.bo(a,null)},
bi(a,b){t.K.a(a)
if(b!=null)A.fv(b)
return this.R("tron_signTransaction",A.a([a],t.f),B.h,t.X)},
ct(a){return this.bi(a,null)},
a9(a,b){var s,r,q
if(b==null||!this.f.a0(a))return
s=this.f.j(0,a)
s.toString
s=A.ab(s,!0,t.g)
for(r=s.length,q=0;q<r;++q)s[q].call(null,b)},
bU(a,b){var s,r
A.h(a)
t.g.a(b)
s=A.be(a)
if(s==null)return
r=this.f.j(0,s)
if(r!=null)B.a.q(r,b)
this.a_(A.aQ(s))},
cL(a,b){var s
A.h(a)
t.g.a(b)
s=this.f.j(0,A.be(a))
if(s!=null)B.a.X(s,b)},
cd(){return this.bB("tron_requestAccounts",B.h,t.c)},
aO(a){t.m.a(a)
return this.R(A.h(a.method),t.r.a(a.params),B.h,t.X)},
gD(){return B.D},
ag(a){var s,r,q,p,o,n,m,l,k,j,i,h,g,f,e,d,c=this,b=null
c.aC(a)
s=t.m
r=s.a(a.data)
q=A.dE(r)
for(p=q.length,o=t.A,n=t.N,m=t.X,l=t.z,k=c.e,j=0;j<q.length;q.length===p||(0,A.c0)(q),++j)switch(q[j]){case B.t:i=o.a(r.account)
h=c.c
g=h==null
f=g?b:A.ak(h.selectedAddress)
e=i==null
if(f!=(e?b:A.h(i.address))){if(!g){g=e?b:A.h(i.address)
h.selectedAddress=g}h=e?b:A.h(i.address)
if(h==null)h=!1
k.base58=h
h=e?b:A.h(i.hex)
if(h==null)h=!1
k.hex=h
s.a(self.window).postMessage(A.f4(A.C(["message",A.C(["action","accountsChanged","data",i],n,m),"source","contentScript"],n,l)))}break
case B.F:c.a9(B.q,r.message)
break
case B.E:h=o.a(r.networkAccounts)
c.a9(B.b,h==null?b:A.h_(h))
break
case B.r:d=o.a(r.chainChanged)
h=c.c
if(h!=null){g=d==null?b:A.h(d.chainId)
h.chainId=g}h=c.c
if(h!=null){g=d==null?b:A.h(d.netVersion)
h.networkVersion=g}if(r.disconnect!=null)c.a9(B.k,r.disconnect)
if(d!=null){if(r.disconnect==null){c.a9(B.i,d)
s.a(self.window).postMessage(A.f4(A.C(["message",A.C(["action","connect","data",null],n,m),"source","contentScript"],n,l)))}h=A.h(d.fullNode)
g=c.d
if(g!=null)g.fullNode=new self.TronWeb.providers.HttpProvider(h)
g=c.d
if(g!=null)g.solidityNode=new self.TronWeb.providers.HttpProvider(h)
g=c.d
if(g!=null)g.setEventServer(new self.TronWeb.providers.HttpProvider(h))
c.a9(B.c,A.h(d.chainId))
s.a(self.window).postMessage(A.f4(A.C(["message",A.C(["action","setNode","data",A.C(["node",d],n,o)],n,m),"source","contentScript"],n,l)))}break}},
A(){return this.M("tron_requestAccounts",t.m)},
F(a){var s=t.m
return this.k("tron_signMessageV2",A.a([s.a(a)],t.O),s)},
K(a){var s=t.m
return this.k("tron_signTransaction",A.a([s.a(a)],t.O),s)},
N(a){var s,r,q=this
q.aK()
s={}
s.connect=A.r(q.gv())
s.version="1.0.0"
a["tron:connect"]=s
s={}
s.signMessage=A.e(q.gE())
s.version="1.0.0"
a["tron:signMessage"]=s
r=q.gJ()
a["tron:signTransaction"]=A.hf(A.e(r))
a["tron:signTransaction"]=A.hf(A.e(r))
a["tron:events"]=A.a1(A.v(q.gH()))}}
A.e4.prototype={
$0(){return this.a.a},
$S:11}
A.e5.prototype={
$0(){return this.a.b},
$S:17}
A.e6.prototype={
$0(){var s,r,q=this.a,p=t.m,o=p.a(self),n=p.a(o.Object),m=p.a(n.create.apply(n,[null]))
m.set=A.fA(q.gaB())
m.get=A.fz(q.gaA())
n=p.a(o.Object)
s=p.a(n.create.apply(n,[null]))
s.get=A.r(new A.e4(q))
n=p.a(o.Object)
n.defineProperty.apply(n,[m,"debugKey",s])
n=p.a(o.Object)
r=p.a(n.create.apply(n,[null]))
r.get=A.r(new A.e5(q))
o=p.a(o.Object)
o.defineProperty.apply(o,[m,"object",r])
return m},
$S:7}
A.dF.prototype={
$1(a){return A.h(a)},
$S:14}
A.dG.prototype={
$1(a){return A.iD(A.h(a))},
$S:56}
A.dz.prototype={
$1(a){return A.h(t.m.a(a).address)},
$S:41};(function aliases(){var s=J.au.prototype
s.bL=s.i
s=A.E.prototype
s.aC=s.ag})();(function installTearOffs(){var s=hunkHelpers._static_1,r=hunkHelpers._static_0,q=hunkHelpers.installInstanceTearOff,p=hunkHelpers._instance_1u,o=hunkHelpers._instance_2u,n=hunkHelpers._instance_0u
s(A,"k3","j4",18)
s(A,"k4","j5",18)
s(A,"k5","j6",18)
r(A,"hL","jY",2)
var m
q(m=A.ae.prototype,"gaB",0,4,null,["$4"],["bE"],44,0,0)
q(m,"gaA",0,3,null,["$3"],["bD"],45,0,0)
p(m=A.ch.prototype,"gbx","az",10)
p(m,"gcC","cD",10)
o(m=A.bh.prototype,"gH","aN",37)
q(m,"gv",0,0,null,["$1","$0"],["a6","A"],58,0,0)
n(m=A.E.prototype,"ga7","cb",3)
o(m,"gH","aN",5)
p(m=A.b5.prototype,"gc1","c2",1)
p(m,"gE","F",1)
p(m,"gJ","K",1)
n(m,"gcO","cP",3)
n(m,"gcu","cv",3)
p(m,"gcw","cz",19)
p(m,"gcA","cB",19)
n(m=A.b8.prototype,"gv","A",3)
p(m,"gbY","bZ",1)
p(m,"gc_","c0",1)
p(m,"gbW","bX",1)
n(m=A.ba.prototype,"gdq","dr",3)
p(m,"gE","F",1)
q(m,"gb9",0,1,null,["$2","$1"],["bb","ba"],21,0,0)
q(m,"gbd",0,1,null,["$2","$1"],["bf","be"],21,0,0)
q(m,"gdk",0,1,null,["$2","$1"],["bp","dl"],21,0,0)
p(m,"gbc","ci",27)
p(m,"gaD","aE",1)
p(m,"gJ","K",1)
p(m=A.bc.prototype,"gao","aO",0)
n(m,"gc4","c5",3)
n(m,"gv","A",3)
p(m,"gaD","aE",0)
p(m,"gde","df",0)
p(m,"gdg","dh",0)
p(m,"gdi","dj",0)
p(m,"gcE","cF",0)
p(m,"gab","ac",0)
o(m,"gbR","bS",5)
o(m,"gcI","cJ",5)
n(m=A.bu.prototype,"gv","A",3)
p(m,"gd0","d1",0)
p(m,"gE","F",0)
p(m,"gd6","d7",1)
p(m,"gcZ","d_",0)
q(m,"gcX",0,1,null,["$2","$1"],["bm","cY"],49,0,0)
n(m=A.bw.prototype,"gv","A",3)
p(m,"gJ","K",1)
p(m,"gab","ac",1)
p(m,"gE","F",0)
q(m=A.bx.prototype,"gcm",0,0,null,["$1","$0"],["bg","cn"],50,0,0)
p(m,"gcq","cr",0)
p(m,"gaY","bG",0)
p(m,"gaX","bF",0)
q(m,"gv",0,0,null,["$1","$0"],["a6","A"],22,0,0)
q(m,"gc6",0,0,null,["$1","$0"],["b6","c7"],22,0,0)
q(m,"gdK",0,0,null,["$1","$0"],["bz","dL"],22,0,0)
p(m,"gaH","ce",27)
p(m,"gco","cp",19)
p(m=A.by.prototype,"gE","F",1)
p(m,"gd4","d5",1)
p(m,"gJ","K",1)
p(m,"gcV","cW",1)
p(m,"gcT","cU",1)
p(m,"gd8","d9",1)
p(m,"gcM","cN",1)
n(m,"gv","A",3)
n(m=A.bz.prototype,"gv","A",3)
p(m,"gJ","K",0)
p(m,"gab","ac",0)
p(m,"gE","F",0)
p(m=A.bA.prototype,"gc9","ca",54)
q(m,"gd2",0,1,null,["$2","$1"],["bn","d3"],12,0,0)
q(m,"gda",0,1,null,["$2","$1"],["bo","dc"],12,0,0)
q(m,"gcs",0,1,null,["$2","$1"],["bi","ct"],12,0,0)
o(m,"gbT","bU",5)
o(m,"gcK","cL",5)
n(m,"gaH","cd",3)
p(m,"gao","aO",0)
n(m,"gv","A",3)
p(m,"gE","F",0)
p(m,"gJ","K",0)})();(function inheritance(){var s=hunkHelpers.mixin,r=hunkHelpers.inherit,q=hunkHelpers.inheritMany
r(A.b,null)
q(A.b,[A.fi,J.cd,J.b6,A.i,A.b9,A.u,A.dV,A.aC,A.bm,A.K,A.e7,A.dP,A.bd,A.bN,A.ap,A.ac,A.dK,A.bk,A.bj,A.cJ,A.cO,A.V,A.cI,A.eN,A.eL,A.bE,A.a8,A.e3,A.aV,A.ai,A.n,A.cF,A.cL,A.bU,A.bI,A.p,A.c8,A.ca,A.ep,A.cs,A.bv,A.eq,A.ad,A.B,A.cM,A.cA,A.dO,A.eI,A.d2,A.e0,A.cP,A.ct,A.ae,A.dj,A.bh,A.E,A.cu])
q(J.cd,[J.ce,J.bg,J.x,J.aM,J.aN,J.cg,J.aL])
q(J.x,[J.au,J.l,A.bn,A.br])
q(J.au,[J.cw,J.bB,J.z])
r(J.dy,J.l)
q(J.cg,[J.bf,J.cf])
q(A.i,[A.aU,A.j,A.aD])
r(A.bV,A.aU)
r(A.bF,A.bV)
r(A.a9,A.bF)
q(A.u,[A.cj,A.af,A.ci,A.cD,A.cG,A.cy,A.b7,A.cH,A.a6,A.bC,A.cC,A.aT,A.c7])
q(A.j,[A.G,A.bl,A.bi,A.bH])
r(A.bb,A.aD)
r(A.M,A.G)
r(A.bt,A.af)
q(A.ap,[A.c4,A.c5,A.cB,A.f0,A.f2,A.em,A.el,A.eP,A.ew,A.eD,A.eG,A.d5,A.f5,A.f8,A.f9,A.eX,A.e9,A.ea,A.dM,A.e1,A.dd,A.dh,A.d1,A.eh,A.ej,A.dR,A.f6,A.dC,A.dr,A.dp,A.dn,A.dH,A.dl,A.du,A.dv,A.cW,A.cX,A.cV,A.dW,A.dF,A.dG,A.dz])
q(A.cB,[A.cz,A.aK])
r(A.cE,A.b7)
q(A.ac,[A.aa,A.bG])
q(A.c5,[A.f1,A.eQ,A.eT,A.ex,A.eE,A.eH,A.dL,A.dN,A.d7,A.d6,A.dA,A.ek,A.ei,A.eg,A.d0,A.cZ])
q(A.br,[A.bo,A.aP])
q(A.aP,[A.bJ,A.bL])
r(A.bK,A.bJ)
r(A.bp,A.bK)
r(A.bM,A.bL)
r(A.bq,A.bM)
q(A.bp,[A.ck,A.cl])
q(A.bq,[A.cm,A.cn,A.co,A.cp,A.cq,A.bs,A.cr])
r(A.bP,A.cH)
q(A.c4,[A.en,A.eo,A.eM,A.d8,A.er,A.ez,A.ey,A.ev,A.et,A.es,A.eC,A.eB,A.eA,A.eF,A.eS,A.eK,A.e2,A.dg,A.df,A.dc,A.de,A.di,A.dB,A.dS,A.dT,A.dU,A.dD,A.ds,A.dq,A.dI,A.dm,A.dk,A.dw,A.dt,A.d_,A.cY,A.dY,A.dZ,A.e_,A.dX,A.e4,A.e5,A.e6])
q(A.aV,[A.ah,A.bO])
r(A.cK,A.bU)
r(A.aW,A.bG)
q(A.a6,[A.aS,A.cc])
r(A.bD,A.cP)
q(A.ep,[A.ar,A.as,A.L,A.U,A.at,A.D,A.cv])
r(A.ch,A.dj)
q(A.E,[A.b5,A.b8,A.ba,A.bc,A.bu,A.bw,A.bx,A.by,A.bz,A.bA])
s(A.bV,A.p)
s(A.bJ,A.p)
s(A.bK,A.K)
s(A.bL,A.p)
s(A.bM,A.K)
s(A.cP,A.d2)})()
var v={typeUniverse:{eC:new Map(),tR:{},eT:{},tPV:{},sEA:[]},mangledGlobalNames:{c:"int",t:"double",b1:"num",k:"String",y:"bool",B:"Null",m:"List",b:"Object",aO:"Map"},mangledNames:{},types:["f(f)","f(b)","~()","f()","0&()","~(k,z)","B(@)","b()","B(b,a2)","k()","~(f)","k?()","f(b[b?])","b?(b?)","k(k)","B(b)","~(@)","b?()","~(~())","~(z)","b(b)","f(k[b?])","f([b?])","B(z,z)","B()","@(@)","y(U)","f(k)","f(k,b)","~(@,@)","y(k,@)","y(as)","y(L)","b?(~)","y(at)","y(D)","F<~>()","z?(k,z)","y(ar)","F<f>()","B(@,a2)","k(f)","B(~())","@(k)","y(b,b?,b?,b?)","b?(b,b?,b?)","c(c)","~(b?,b?)","b(b,a2)","f(l<b?>[f?])","f([y?])","~(c,@)","l<b?>(f)","F<f?>()","~(b?)","k(c)","L(k)","@(@,k)","f([f?])"],interceptorsByTag:null,leafTags:null,arrayRti:Symbol("$ti"),rttc:{}}
A.jl(v.typeUniverse,JSON.parse('{"z":"au","cw":"au","bB":"au","l":{"m":["1"],"x":[],"j":["1"],"f":[],"i":["1"]},"ce":{"y":[],"q":[]},"bg":{"B":[],"q":[]},"x":{"f":[]},"au":{"x":[],"f":[]},"dy":{"l":["1"],"m":["1"],"x":[],"j":["1"],"f":[],"i":["1"]},"b6":{"T":["1"]},"cg":{"t":[],"b1":[]},"bf":{"t":[],"c":[],"b1":[],"q":[]},"cf":{"t":[],"b1":[],"q":[]},"aL":{"k":[],"h6":[],"q":[]},"aU":{"i":["2"]},"b9":{"T":["2"]},"bF":{"p":["2"],"m":["2"],"aU":["1","2"],"j":["2"],"i":["2"]},"a9":{"bF":["1","2"],"p":["2"],"m":["2"],"aU":["1","2"],"j":["2"],"i":["2"],"p.E":"2","i.E":"2"},"cj":{"u":[]},"j":{"i":["1"]},"G":{"j":["1"],"i":["1"]},"aC":{"T":["1"]},"aD":{"i":["2"],"i.E":"2"},"bb":{"aD":["1","2"],"j":["2"],"i":["2"],"i.E":"2"},"bm":{"T":["2"]},"M":{"G":["2"],"j":["2"],"i":["2"],"G.E":"2","i.E":"2"},"bt":{"af":[],"u":[]},"ci":{"u":[]},"cD":{"u":[]},"bN":{"a2":[]},"ap":{"aB":[]},"c4":{"aB":[]},"c5":{"aB":[]},"cB":{"aB":[]},"cz":{"aB":[]},"aK":{"aB":[]},"cG":{"u":[]},"cy":{"u":[]},"cE":{"u":[]},"aa":{"ac":["1","2"],"h2":["1","2"],"aO":["1","2"]},"bl":{"j":["1"],"i":["1"],"i.E":"1"},"bk":{"T":["1"]},"bi":{"j":["ad<1,2>"],"i":["ad<1,2>"],"i.E":"ad<1,2>"},"bj":{"T":["ad<1,2>"]},"bn":{"x":[],"f":[],"c3":[],"q":[]},"br":{"x":[],"f":[]},"cO":{"c3":[]},"bo":{"x":[],"fe":[],"f":[],"q":[]},"aP":{"Q":["1"],"x":[],"f":[]},"bp":{"p":["t"],"m":["t"],"Q":["t"],"x":[],"j":["t"],"f":[],"i":["t"],"K":["t"]},"bq":{"p":["c"],"m":["c"],"Q":["c"],"x":[],"j":["c"],"f":[],"i":["c"],"K":["c"]},"ck":{"d3":[],"p":["t"],"m":["t"],"Q":["t"],"x":[],"j":["t"],"f":[],"i":["t"],"K":["t"],"q":[],"p.E":"t"},"cl":{"d4":[],"p":["t"],"m":["t"],"Q":["t"],"x":[],"j":["t"],"f":[],"i":["t"],"K":["t"],"q":[],"p.E":"t"},"cm":{"d9":[],"p":["c"],"m":["c"],"Q":["c"],"x":[],"j":["c"],"f":[],"i":["c"],"K":["c"],"q":[],"p.E":"c"},"cn":{"da":[],"p":["c"],"m":["c"],"Q":["c"],"x":[],"j":["c"],"f":[],"i":["c"],"K":["c"],"q":[],"p.E":"c"},"co":{"db":[],"p":["c"],"m":["c"],"Q":["c"],"x":[],"j":["c"],"f":[],"i":["c"],"K":["c"],"q":[],"p.E":"c"},"cp":{"eb":[],"p":["c"],"m":["c"],"Q":["c"],"x":[],"j":["c"],"f":[],"i":["c"],"K":["c"],"q":[],"p.E":"c"},"cq":{"ec":[],"p":["c"],"m":["c"],"Q":["c"],"x":[],"j":["c"],"f":[],"i":["c"],"K":["c"],"q":[],"p.E":"c"},"bs":{"ed":[],"p":["c"],"m":["c"],"Q":["c"],"x":[],"j":["c"],"f":[],"i":["c"],"K":["c"],"q":[],"p.E":"c"},"cr":{"ee":[],"p":["c"],"m":["c"],"Q":["c"],"x":[],"j":["c"],"f":[],"i":["c"],"K":["c"],"q":[],"p.E":"c"},"cH":{"u":[]},"bP":{"af":[],"u":[]},"bE":{"c6":["1"]},"a8":{"u":[]},"aV":{"c6":["1"]},"ah":{"aV":["1"],"c6":["1"]},"bO":{"aV":["1"],"c6":["1"]},"n":{"F":["1"]},"bU":{"hj":[]},"cK":{"bU":[],"hj":[]},"bG":{"ac":["1","2"],"aO":["1","2"]},"aW":{"bG":["1","2"],"ac":["1","2"],"aO":["1","2"]},"bH":{"j":["1"],"i":["1"],"i.E":"1"},"bI":{"T":["1"]},"ac":{"aO":["1","2"]},"t":{"b1":[]},"c":{"b1":[]},"m":{"j":["1"],"i":["1"]},"k":{"h6":[]},"b7":{"u":[]},"af":{"u":[]},"a6":{"u":[]},"aS":{"u":[]},"cc":{"u":[]},"bC":{"u":[]},"cC":{"u":[]},"aT":{"u":[]},"c7":{"u":[]},"cs":{"u":[]},"bv":{"u":[]},"cM":{"a2":[]},"b5":{"E":[]},"b8":{"E":[]},"ba":{"E":[]},"bc":{"E":[]},"bu":{"E":[]},"bw":{"E":[]},"bx":{"E":[]},"by":{"E":[]},"bz":{"E":[]},"bA":{"E":[]},"db":{"m":["c"],"j":["c"],"i":["c"]},"ee":{"m":["c"],"j":["c"],"i":["c"]},"ed":{"m":["c"],"j":["c"],"i":["c"]},"d9":{"m":["c"],"j":["c"],"i":["c"]},"eb":{"m":["c"],"j":["c"],"i":["c"]},"da":{"m":["c"],"j":["c"],"i":["c"]},"ec":{"m":["c"],"j":["c"],"i":["c"]},"d3":{"m":["t"],"j":["t"],"i":["t"]},"d4":{"m":["t"],"j":["t"],"i":["t"]}}'))
A.jk(v.typeUniverse,JSON.parse('{"bV":2,"aP":1}'))
var u={c:"Error handler must accept one Object or one Object and a StackTrace as arguments, and return a value of the returned future's type",f:"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAhGVYSWZNTQAqAAAACAAFARIAAwAAAAEAAQAAARoABQAAAAEAAABKARsABQAAAAEAAABSASgAAwAAAAEAAgAAh2kABAAAAAEAAABaAAAAAAAAAEgAAAABAAAASAAAAAEAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAIKADAAQAAAABAAAAIAAAAABfvA/wAAAACXBIWXMAAAsTAAALEwEAmpwYAAACyGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNi4wLjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyIKICAgICAgICAgICAgeG1sbnM6ZXhpZj0iaHR0cDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iPgogICAgICAgICA8dGlmZjpZUmVzb2x1dGlvbj43MjwvdGlmZjpZUmVzb2x1dGlvbj4KICAgICAgICAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+MjwvdGlmZjpSZXNvbHV0aW9uVW5pdD4KICAgICAgICAgPHRpZmY6WFJlc29sdXRpb24+NzI8L3RpZmY6WFJlc29sdXRpb24+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWERpbWVuc2lvbj41MDwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOkNvbG9yU3BhY2U+MTwvZXhpZjpDb2xvclNwYWNlPgogICAgICAgICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+NTA8L2V4aWY6UGl4ZWxZRGltZW5zaW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KZxgR6QAAB6lJREFUWAnlVmlsXFcZPfe9ecvsYzt2SihSk1SQBUWCqKUJSEkQyw+qSqXEKhKFssROLSTU0MQJAtUI0WYtKkJpYtqoqBJLDAXyB4kSakUlZSkCEtwQoRYqJXU2e+zxvHnztns5903sOBlH6o9KCHGleXPX7zvfud9ygf/3Jm5CgIDiil6d/W/1brJ9wem3Q8aCgudPaog3M2L+vpv22w8rJbB7oAJlGAhtBTsUCFWARw96VKUwNGQAowYeHU3SsRat2BvZbODV1XpdckZgaCAPWzhzMoSU2HlwCkJoTufafAC6TwEPVuDaJyDUOyHRgGE6sIwAnrcR3/jBa3Mn9z2Qzwb5ih6XnMLUxe37vbm1x7+wDLYzili5kEkAAzkocR7K3IBdT1W5r6WLnczcodmOk+VisgSm2QkTnem0lIOp8r4+C8vFRii5AgngZ2So1wM1bWf3PkQ9yVmvjBfRP/w6DvR/F4bYRzktyTEPKI/sXd/aAWCaG3MNwOyiokkk8b3Y+cwJ7N6ynuOPIjFPIxONdKNUtExVqFgWlIrrZ86Nz6CQXWcju8vcu/W4/9VD+7G77/fIGD+nwYu4qQHXuo5+DaUNUYrPJO3a/RPMKt9CCtchmD6QyVpTrlF80i26v+ypVH5V4e8dXYuPfWLN+568f9XaWnj6Fwf8RN7p7u3vw87hlxDLe6mcmgwHzUhTn4pO//lpBxAUAphGk0uD2Hn4BB7bsoW+0ISTPyhyHc/GGfN4T6nQ223ZK0UcL+4yrMXvLvesqJRLvaZj/ubT9ww+N/TetYebSeTNgTCM7bBMH5aiXLYWjBu76bj1GaITDR15Hfv619GR1iPAU8gbLxuuvUb6UXRnpVvcVu4ywjgQPbkibNNQkYxlV66opo3Eqk3X/r7cdj8wdPqVrdmM+Qd/x6HfYVbmPDW6e9VDbpgd/UuV4ZSBWXsQgfU95NWzcJ1Nqu43y5btCEijk3+3FMuiaLlCCIjufMlwbNv0/EbTzueWnPfqK0+/9MzXjZ73fCZZtvYkDjw9cYOWdNh+BWmccy07voEXNIZifAds61Oo+xFj2E3jh3dqCh7l1dJyFJ0s8vzpccYw3LjeiEzH+uT99+y4KwzD03kdObrNyk4HrU87gFVjVx1FrkIkTiJSfVowf0LTVZMJOqnMtR36l8Qlr4bxmUl4QRN2JoOsaSOKY6YdiZlm0IfEO0mGVrTUjbbpa7+Co2NAuZZl+L0fInmD1n8FUvYYUmkcwjZMLCt1IWfZCKIA9cAnC0x+ZMU2LW5VqPp1eGEomioxGD3PX46S23s+vmrM+9qxEN9sQZn9tiFKU6XvVchxyKsuMJl0IpEMBCUUre+2s5zOoBGFDBYLHXRCl4oNXkkjJKCwiZkwEF4QoCFlpysyBYk4nJFWmd6vuZwXAwtlwllokjVBN202f0Uzg9hQyLkuM5/Em14dJgEtrXSjSFAhWfB9D5ONGVQ1K2SkQfO8KGJEU4LOBQu0dgZ0McrmWTSk5Vhihrl8suQ4eFdHj7qtczHLgonppod/1qp4g1T/7cp5XKLSehzhvJ6bmUI9itS0jDAdBpMXkrDOYHMaRjSt/ahl0jUk7QBGeg1s+46vGQ8iFqNInqrT8su1qozjmDfEmKOkDEU1mN/HSfUEHbBGSyXB1QhkIgzkJFm60vBPBQhoBH1k+3NeWjGv6U577QB0SU2bOMMw/BAy5jD9Cpf8umrS6bR3K9J5a2URlhQruCVfhk9QV+gT434D50n/lShQlzmuy2gYifVB3uE/UpFzslsa9LcdQKueA0snR3lwJWT4ZxWGP3E6ylYpV2henKmiQYuTpPUcsDMm7z9OPf/s1GWm+7DpOaaVNPyfwpv4I+laDf/WF1OVs7Kv6V8AgF781ueWo3eEGtSvyetWjFc/Hzb8v/47nHEbcRyVcsV4oj4tz05cUOeql9WFqQn5WvVSzKQUiULOhd88BWvys3A6+hkqLzABxanMeYpnu/PzQMvrH3kgj47CK/jYHQ52HP4xPrJ2BfLualyobgtt83bpWGtCFRuTUUBnEKIpE+FDCuU6hiAdvKcRZCbvRljezPiJMTh8DPsHdjCfHML6pcMYfVW/IVq62Gm/gq6CzSRkM/4ex7f7NmHX94+k+3rKX16EeIv0401TtdoPlRBjTH3jwrHGRSYzhiD4kWqGH4YKv4ioY4BPOhu7hp9mNd0AyD2IKTPIssyzXfUy3V34QSJzLMkkxzJ+RhD3UdAR7PnSXVeU+TCFncllzUca9YTPrKSkXIZIIuuQpoeMpMNxjxAvYPDwy9hL5Yb5fGqw5Luy++qDZM7+BQGUuZ/CNUxDdMAxf4snBnZh28HdOLr5T/hX58ZGqO6DTfaUGSBh3lAsABkmS5hn0Dj7GIZGYxx4aJAidmsrW9lM5NDkA/eG1s6AYN6FOsdKo7NXgynZoVUDdKIR9KaP0uOUcRxPPJyFTtn6OnXi0rljtunaDwwwZi+SnYCM5LjtTYg8ZV/f2hBRqcCe/hKtMuD6Ck0+UgO+bIeG+U5k0yVVV8zNRyUFt25Tn9EJ7NqznPv6cmTPmZOhDRs8XJs7cz2O/96onYEWloXm5/nuWwL8dsh4S4r+tzf9Bwpfgk0+0buPAAAAAElFTkSuQmCC"}
var t=(function rtii(){var s=A.aI
return{n:s("a8"),B:s("c3"),Y:s("fe"),V:s("j<@>"),C:s("u"),E:s("d3"),W:s("d4"),Z:s("aB"),t:s("F<@>"),w:s("d9"),k:s("da"),by:s("db"),R:s("i<@>"),bU:s("i<b?>"),aV:s("ar"),O:s("l<f>"),I:s("l<z>"),f:s("l<b>"),s:s("l<k>"),bx:s("l<y>"),b:s("l<@>"),c:s("l<b?>"),D:s("D"),G:s("U"),cA:s("L"),T:s("bg"),m:s("f"),cP:s("as"),c9:s("at"),g:s("z"),da:s("Q<@>"),e:s("x"),cx:s("m<f>"),u:s("m<z>"),a:s("m<k>"),j:s("m<@>"),co:s("aO<D,E>"),bC:s("aO<@,@>"),P:s("B"),K:s("b"),p:s("ct"),o:s("ae<b>"),cY:s("kv"),cD:s("+()"),l:s("a2"),N:s("k"),bW:s("q"),b7:s("af"),c0:s("eb"),bk:s("ec"),ca:s("ed"),bX:s("ee"),cr:s("bB"),d5:s("E"),x:s("ah<f>"),h:s("ah<~>"),aX:s("n<f>"),d:s("n<@>"),U:s("n<~>"),J:s("aW<b?,b?>"),b5:s("bO<~>"),y:s("y"),bG:s("y(b)"),i:s("t"),z:s("@"),bd:s("@()"),v:s("@(b)"),Q:s("@(b,a2)"),S:s("c"),L:s("0&*"),_:s("b*"),bc:s("F<B>?"),r:s("l<b?>?"),A:s("f?"),X:s("b?"),cZ:s("ae<b>?"),F:s("ai<@,@>?"),q:s("b1"),H:s("~"),M:s("~()")}})();(function constants(){var s=hunkHelpers.makeConstList
B.X=J.cd.prototype
B.a=J.l.prototype
B.f=J.bf.prototype
B.l=J.aL.prototype
B.a0=J.z.prototype
B.a1=J.x.prototype
B.a7=A.bo.prototype
B.P=J.cw.prototype
B.H=J.bB.prototype
B.I=new A.ca()
B.J=function getTagFallback(o) {
  var s = Object.prototype.toString.call(o);
  return s.substring(8, s.length - 1);
}
B.Q=function() {
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
B.V=function(getTagFallback) {
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
B.R=function(hooks) {
  if (typeof dartExperimentalFixupGetTag != "function") return hooks;
  hooks.getTag = dartExperimentalFixupGetTag(hooks.getTag);
}
B.U=function(hooks) {
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
B.T=function(hooks) {
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
B.S=function(hooks) {
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
B.K=function(hooks) { return hooks; }

B.W=new A.cs()
B.n=new A.dV()
B.e=new A.cK()
B.o=new A.cM()
B.p=new A.ar("Rejected","rejected")
B.u=new A.D("aptos")
B.v=new A.D("bitcoin")
B.w=new A.D("cosmos")
B.x=new A.D("ethereum")
B.y=new A.D("solana")
B.z=new A.D("stellar")
B.A=new A.D("substrate")
B.B=new A.D("sui")
B.C=new A.D("ton")
B.D=new A.D("tron")
B.b=new A.U("accountsChanged")
B.c=new A.U("chainChanged")
B.q=new A.U("message")
B.i=new A.U("connect")
B.k=new A.U("disconnect")
B.d=new A.U("change")
B.E=new A.L("networkAccountsChanged")
B.L=new A.L("change")
B.r=new A.L("defaultChainChanged")
B.t=new A.L("defaultAccountChanged")
B.F=new A.L("message")
B.M=new A.as("response")
B.N=new A.at("success")
B.G=new A.at("failed")
B.O=A.a(s([B.b,B.c,B.q,B.i,B.k,B.d]),A.aI("l<U>"))
B.a_=new A.as("event")
B.a2=A.a(s([B.M,B.a_]),A.aI("l<as>"))
B.Z=new A.D("global")
B.a3=A.a(s([B.Z,B.x,B.D,B.y,B.C,B.z,B.A,B.u,B.B,B.v,B.w]),A.aI("l<D>"))
B.a4=A.a(s([B.E,B.L,B.r,B.t,B.F]),A.aI("l<L>"))
B.Y=new A.ar("Approved","approved")
B.a5=A.a(s([B.Y,B.p]),A.aI("l<ar>"))
B.a6=A.a(s([B.N,B.G]),A.aI("l<at>"))
B.m=new A.cv("walletStandard")
B.h=new A.cv("eip1993")
B.a8=A.a0("c3")
B.a9=A.a0("fe")
B.aa=A.a0("d3")
B.ab=A.a0("d4")
B.ac=A.a0("d9")
B.ad=A.a0("da")
B.ae=A.a0("db")
B.af=A.a0("b")
B.ag=A.a0("eb")
B.ah=A.a0("ec")
B.ai=A.a0("ed")
B.aj=A.a0("ee")
B.j=new A.bD("An error occurred during the request",-32603)})();(function staticFields(){$.eJ=null
$.S=A.a([],t.f)
$.h7=null
$.fQ=null
$.fP=null
$.hP=null
$.hK=null
$.hU=null
$.eZ=null
$.f3=null
$.fH=null
$.kK=A.a([],A.aI("l<m<b>?>"))
$.aX=null
$.bW=null
$.bX=null
$.fC=!1
$.o=B.e})();(function lazyInitializers(){var s=hunkHelpers.lazyFinal
s($,"kr","b2",()=>A.kd("_$dart_dartClosure"))
s($,"kz","i0",()=>A.ag(A.e8({
toString:function(){return"$receiver$"}})))
s($,"kA","i1",()=>A.ag(A.e8({$method$:null,
toString:function(){return"$receiver$"}})))
s($,"kB","i2",()=>A.ag(A.e8(null)))
s($,"kC","i3",()=>A.ag(function(){var $argumentsExpr$="$arguments$"
try{null.$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kF","i6",()=>A.ag(A.e8(void 0)))
s($,"kG","i7",()=>A.ag(function(){var $argumentsExpr$="$arguments$"
try{(void 0).$method$($argumentsExpr$)}catch(r){return r.message}}()))
s($,"kE","i5",()=>A.ag(A.hg(null)))
s($,"kD","i4",()=>A.ag(function(){try{null.$method$}catch(r){return r.message}}()))
s($,"kI","i9",()=>A.ag(A.hg(void 0)))
s($,"kH","i8",()=>A.ag(function(){try{(void 0).$method$}catch(r){return r.message}}()))
s($,"kJ","fM",()=>A.j3())
s($,"kU","fa",()=>A.cR(B.af))
s($,"kV","ia",()=>Symbol("jsBoxedDartObjectProperty"))
s($,"ku","hY",()=>{var r=new A.eI(new DataView(new ArrayBuffer(8)))
r.bN()
return r})
s($,"kt","fL",()=>({message:"this feature disabled by wallet provider."}))
s($,"ks","hX",()=>({uuid:"466aef37-e077-42d1-b26b-801ff1af4a36",name:"MRT",icon:u.f,rdns:"com.mrtnetwork.wallet"}))
s($,"kw","hZ",()=>A.iH(A.a(["legacy",0],t.f),t.K))
s($,"ky","i_",()=>({message:"Invalid Sui transaction. The transaction must include transactionBlock with the blockData property for v1, or transaction with the toJSON property for v2."}))})();(function nativeSupport(){!function(){var s=function(a){var m={}
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
hunkHelpers.setOrUpdateInterceptorsByTag({ArrayBuffer:A.bn,ArrayBufferView:A.br,DataView:A.bo,Float32Array:A.ck,Float64Array:A.cl,Int16Array:A.cm,Int32Array:A.cn,Int8Array:A.co,Uint16Array:A.cp,Uint32Array:A.cq,Uint8ClampedArray:A.bs,CanvasPixelArray:A.bs,Uint8Array:A.cr})
hunkHelpers.setOrUpdateLeafTags({ArrayBuffer:true,ArrayBufferView:false,DataView:true,Float32Array:true,Float64Array:true,Int16Array:true,Int32Array:true,Int8Array:true,Uint16Array:true,Uint32Array:true,Uint8ClampedArray:true,CanvasPixelArray:true,Uint8Array:false})
A.aP.$nativeSuperclassTag="ArrayBufferView"
A.bJ.$nativeSuperclassTag="ArrayBufferView"
A.bK.$nativeSuperclassTag="ArrayBufferView"
A.bp.$nativeSuperclassTag="ArrayBufferView"
A.bL.$nativeSuperclassTag="ArrayBufferView"
A.bM.$nativeSuperclassTag="ArrayBufferView"
A.bq.$nativeSuperclassTag="ArrayBufferView"})()
Function.prototype.$2=function(a,b){return this(a,b)}
Function.prototype.$0=function(){return this()}
Function.prototype.$1=function(a){return this(a)}
Function.prototype.$3=function(a,b,c){return this(a,b,c)}
Function.prototype.$4=function(a,b,c,d){return this(a,b,c,d)}
Function.prototype.$1$1=function(a){return this(a)}
convertAllToFastObject(w)
convertToFastObject($);(function(a){if(typeof document==="undefined"){a(null)
return}if(typeof document.currentScript!="undefined"){a(document.currentScript)
return}var s=document.scripts
function onLoad(b){for(var q=0;q<s.length;++q){s[q].removeEventListener("load",onLoad,false)}a(b.target)}for(var r=0;r<s.length;++r){s[r].addEventListener("load",onLoad,false)}})(function(a){v.currentScript=a
var s=function(b){return A.fJ(A.k8(b))}
if(typeof dartMainRunner==="function"){dartMainRunner(s,[])}else{s([])}})})()