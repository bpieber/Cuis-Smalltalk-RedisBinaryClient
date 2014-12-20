'From Cuis 4.2 of 25 July 2013 [latest update: #2093] on 29 November 2014 at 10:35:14.542825 pm'!
'Description Please enter a description for this package'!
!provides: 'RedisBinaryClient' 1 2!
!requires: 'SqueakCompatibility' 1 6 nil!
!requires: 'Network-Kernel' 1 2 nil!
!classDefinition: #SSSRedisError category: #RedisBinaryClient!
Error subclass: #SSSRedisError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'RedisBinaryClient'!
!classDefinition: 'SSSRedisError class' category: #RedisBinaryClient!
SSSRedisError class
	instanceVariableNames: ''!

!classDefinition: #SSSRedisConnection category: #RedisBinaryClient!
Object subclass: #SSSRedisConnection
	instanceVariableNames: 'port hostname pubsub timeout listener stream'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'RedisBinaryClient'!
!classDefinition: 'SSSRedisConnection class' category: #RedisBinaryClient!
SSSRedisConnection class
	instanceVariableNames: ''!

!classDefinition: #SSSRedisConnectionTest category: #'RedisBinaryClient-Tests'!
TestCase subclass: #SSSRedisConnectionTest
	instanceVariableNames: 'connection'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'RedisBinaryClient-Tests'!
!classDefinition: 'SSSRedisConnectionTest class' category: #'RedisBinaryClient-Tests'!
SSSRedisConnectionTest class
	instanceVariableNames: ''!


!Dictionary methodsFor: '*redisbinaryclient' stamp: 'DirkPorsche 6/17/2011 22:13'!
flattened
	| result |
	result := OrderedCollection new.
	self associationsDo: [ :assoc | 
		result add: assoc key. 
		result add: assoc value ].
	^ result.! !

!SSSRedisConnection methodsFor: 'transactions' stamp: 'mlh 8/31/2010 20:44'!
atomic: aBlock 
	self multi.
	aBlock value.
	^ self exec! !

!SSSRedisConnection methodsFor: 'transactions' stamp: 'mlh 8/31/2010 20:44'!
atomic: aBlock watch: keys 
	self watch: keys.
	self multi.
	aBlock value.
	^ self exec! !

!SSSRedisConnection methodsFor: 'commands-connection' stamp: 'mlh 3/15/2011 15:43'!
auth: password
	^ self
		unifiedCommand:
			{'AUTH'.
			password}! !

!SSSRedisConnection methodsFor: 'commands-server' stamp: 'mlh 1/14/2010 21:46'!
beMaster
	^ self inlineCommand: 'SLAVEOF no one'! !

!SSSRedisConnection methodsFor: 'commands-server' stamp: 'mlh 1/14/2010 21:43'!
bgRewriteAOF
	^ self inlineCommand: 'BGREWRITEAOF'! !

!SSSRedisConnection methodsFor: 'commands-server' stamp: 'mlh 1/14/2010 21:41'!
bgSave
	^ self inlineCommand: 'BGSAVE'! !

!SSSRedisConnection methodsFor: 'private replies' stamp: 'DirkPorsche 6/17/2011 11:49'!
binaryCrLf
	^ (ByteArray with: Character cr asUnicode with: Character lf asUnicode)! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 15:52'!
blPop: keys timeout: seconds
	^ self unifiedCommand: {'BLPOP'} , keys , {seconds}! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 15:50'!
brPop: keys timeout: seconds
	^ self unifiedCommand: {'BRPOP'} , keys , {seconds}! !

!SSSRedisConnection methodsFor: 'private connection' stamp: 'DirkPorsche 6/16/2011 11:21'!
connect
	stream
		ifNil: [ 
			stream := SocketStream openConnectionToHostNamed: hostname port: port.
			stream binary]! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'MLH 1/6/2010 17:04'!
dbSize
	^ self inlineCommand: 'DBSIZE'! !

!SSSRedisConnection methodsFor: 'commands-strings' stamp: 'mlh 3/15/2011 14:42'!
decr: aKey
	^ (self
		unifiedCommand:
			{'DECR'.
			aKey}) asNumber! !

!SSSRedisConnection methodsFor: 'commands-strings' stamp: 'mlh 3/15/2011 15:39'!
decr: aKey by: anInteger
	^ (self
		unifiedCommand:
			{'DECRBY'.
			aKey.
			anInteger}) asNumber! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'mlh 3/15/2011 14:47'!
del: keys
	^ self unifiedCommand: {'DEL'} , keys! !

!SSSRedisConnection methodsFor: 'commands-transactions' stamp: 'mlh 8/31/2010 20:40'!
discard
	^ self inlineCommand: 'DISCARD'! !

!SSSRedisConnection methodsFor: 'private connection' stamp: 'DirkPorsche 6/16/2011 11:04'!
disconnect
	pubsub
		ifTrue: [[self unsubscribe] on: Error do: [ :ex |].
			listener ifNotNil: [listener terminate].
			self exitPubsub]. 
	stream
		ifNotNil: [[stream close] on: Error do: [:ex|].
			stream := nil].! !

!SSSRedisConnection methodsFor: 'private' stamp: 'mlh 3/15/2011 15:42'!
enterPubsub
	pubsub := true.! !

!SSSRedisConnection methodsFor: 'commands-transactions' stamp: 'mlh 8/31/2010 20:40'!
exec
	^ self inlineCommand: 'EXEC'! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'mlh 3/15/2011 15:44'!
exists: aKey
	^ (self
		unifiedCommand:
			{'EXISTS'.
			aKey}) = 1! !

!SSSRedisConnection methodsFor: 'private' stamp: 'mlh 3/15/2011 15:42'!
exitPubsub
	pubsub := false.
	listener := nil.
	! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'mlh 3/15/2011 15:48'!
expire: aKey at: aDateAndTime
	^ self
		unifiedCommand:
			{'EXPIREAT'.
			aKey.
			(aDateAndTime asUnixTime)}! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'mlh 3/15/2011 15:49'!
expire: aKey seconds: seconds
	^ self
		unifiedCommand:
			{'EXPIRE'.
			aKey.
			seconds}! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'MLH 1/6/2010 17:20'!
flushAll
	^ self inlineCommand: 'FLUSHALL'! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'MLH 1/6/2010 17:20'!
flushDb
	^ self inlineCommand: 'FLUSHDB'! !

!SSSRedisConnection methodsFor: 'commands-strings' stamp: 'mlh 3/15/2011 12:27'!
get: aKey
	^ self
		unifiedCommand:
			{'GET'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-strings' stamp: 'mlh 3/15/2011 15:39'!
getSet: aKey value: aValue
	^ self
		unifiedCommand:
			{'GETSET'.
			aKey.
			aValue}! !

!SSSRedisConnection methodsFor: 'commands-hashes' stamp: 'mlh 3/15/2011 14:52'!
hDel: aKey field: aField 
	^ self unifiedCommand: {'HDEL' . aKey. aField}! !

!SSSRedisConnection methodsFor: 'commands-hashes' stamp: 'mlh 3/15/2011 14:52'!
hExists: aKey field: aField 
	^ (self unifiedCommand: {'HEXISTS' . aKey. aField})
		= 1 ! !

!SSSRedisConnection methodsFor: 'commands-hashes' stamp: 'mlh 3/15/2011 14:53'!
hGet: aKey field: aField 
	^ self unifiedCommand:    {'HGET' . aKey. aField}! !

!SSSRedisConnection methodsFor: 'commands-hashes' stamp: 'mlh 3/15/2011 15:45'!
hGetAll: aKey
	^ Dictionary
		newFromPairs:
			(self
				unifiedCommand:
					{'HGETALL'.
					aKey})! !

!SSSRedisConnection methodsFor: 'commands-hashes' stamp: 'mlh 3/15/2011 14:54'!
hIncrBy: key field: field value: value 
	^ self unifiedCommand:  {'HINCRBY'. key. field. value}
	! !

!SSSRedisConnection methodsFor: 'commands-hashes' stamp: 'mlh 3/15/2011 15:45'!
hKeys: aKey
	^ self
		unifiedCommand:
			{'HKEYS'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-hashes' stamp: 'mlh 3/15/2011 15:46'!
hLen: aKey
	^ self
		unifiedCommand:
			{'HLEN'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-hashes' stamp: 'mlh 3/15/2011 14:55'!
hMGet: aKey fields: fields 
	^ self unifiedCommand: {'HMGET' . aKey}, fields! !

!SSSRedisConnection methodsFor: 'commands-hashes' stamp: 'mlh 3/15/2011 15:53'!
hMSet: aKey dictionary: aDictionary
	^ self
		unifiedCommand:
			{'HMSET'.
			aKey} , aDictionary flattened! !

!SSSRedisConnection methodsFor: 'commands-hashes' stamp: 'mlh 3/15/2011 14:51'!
hSet: key field: field value: value 
	^ self unifiedCommand: {'HSET'. key. field. value}! !

!SSSRedisConnection methodsFor: 'commands-hashes' stamp: 'mlh 3/15/2011 15:45'!
hVals: aKey
	^ self
		unifiedCommand:
			{'HVALS'.
			aKey}! !

!SSSRedisConnection methodsFor: 'accessing' stamp: 'MLH 1/5/2010 21:42'!
hostname
	^ hostname! !

!SSSRedisConnection methodsFor: 'accessing' stamp: 'MLH 1/5/2010 21:42'!
hostname: anObject
	hostname := anObject! !

!SSSRedisConnection methodsFor: 'commands-strings' stamp: 'mlh 3/15/2011 15:39'!
incr: aKey
	^ (self
		unifiedCommand:
			{'INCR'.
			aKey}) asNumber! !

!SSSRedisConnection methodsFor: 'commands-strings' stamp: 'mlh 3/15/2011 15:40'!
incr: aKey by: anInteger
	^ (self
		unifiedCommand:
			{'INCRBY'.
			aKey.
			anInteger}) asNumber! !

!SSSRedisConnection methodsFor: 'commands-connection' stamp: 'mlh 3/15/2011 12:34'!
info
	^ self unifiedCommand: {'INFO'}! !

!SSSRedisConnection methodsFor: 'initialize-release' stamp: 'mlh 3/15/2011 09:59'!
initialize
	pubsub := false.
	timeout := 30! !

!SSSRedisConnection methodsFor: 'private commands' stamp: 'DirkPorsche 6/16/2011 11:05'!
inlineCommand: aCommandString 
	stream nextPutAll: aCommandString;
		 crlf;
		 flush.
	^ self reply! !

!SSSRedisConnection methodsFor: 'testing' stamp: 'DirkPorsche 6/16/2011 11:06'!
isConnected
	^stream notNil and: [ stream isConnected ]! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'mlh 3/15/2011 15:47'!
keys: aPattern
	^ self
		unifiedCommand:
			{'KEYS'.
			aPattern}! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 15:48'!
lIndex: aKey value: aValue
	^ self
		unifiedCommand:
			{'LINDEX'.
			aKey.
			aValue}! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 15:46'!
lLen: aKey
	^ self
		unifiedCommand:
			{'LLEN'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 15:46'!
lPop: aKey
	^ self
		unifiedCommand:
			{'LPOP'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 14:56'!
lPush: aKey value: aValue 
	^ self
		unifiedCommand: { 'LPUSH'
		. aKey
		. aValue}! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 14:56'!
lRange: aKey start: startIndex end: endIndex 
	^ self unifiedCommand: {'LRANGE' . aKey. startIndex. endIndex}! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 14:57'!
lRem: aKey count: aCount value: aValue 
	^ self unifiedCommand: {'LREM' .aKey. aCount. aValue}! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 14:58'!
lSet: aKey index: anIndex value: aValue 
	^ self unifiedCommand: {'LSET' .aKey. anIndex. aValue}! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 14:58'!
lTrim: aKey start: startIndex end: endIndex 
	^ self unifiedCommand: {'LTRIM'  .aKey. startIndex. endIndex}! !

!SSSRedisConnection methodsFor: 'commands-server' stamp: 'mlh 1/14/2010 21:42'!
lastSave
	^ self inlineCommand: 'LASTSAVE'! !

!SSSRedisConnection methodsFor: 'commands-strings' stamp: 'mlh 3/15/2011 15:40'!
mGet: keys
	^ self unifiedCommand: {'MGET'} , keys! !

!SSSRedisConnection methodsFor: 'commands-strings' stamp: 'mlh 3/15/2011 15:40'!
mSet: aDictionary
	^ self unifiedCommand: {'MSET'} , aDictionary flattened! !

!SSSRedisConnection methodsFor: 'commands-strings' stamp: 'mlh 3/15/2011 15:41'!
mSetNx: aDictionary
	^ self unifiedCommand: {'MSETNX'} , aDictionary flattened! !

!SSSRedisConnection methodsFor: 'commands-server' stamp: 'DirkPorsche 6/16/2011 11:07'!
monitor: aStream 
	stream nextPutAll: 'MONITOR';
		 crlf;
		 flush.
	[[[stream atEnd]
		whileFalse: [aStream
				write: (stream upToAll: String crlf);
				write: String crlf;
				flush]]
		on: Error
		do: [:ex | aStream nextPutAll: 'Connection Closed';
				 nextPutAll: String crlf;
				 flush]] fork! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'mlh 3/15/2011 15:54'!
move: aKey to: zeroBasedDbIndex
	^ self
		unifiedCommand:
			{'MOVE'.
			aKey.
			zeroBasedDbIndex}! !

!SSSRedisConnection methodsFor: 'commands-transactions' stamp: 'mlh 8/31/2010 20:40'!
multi
	^ self inlineCommand: 'MULTI'! !

!SSSRedisConnection methodsFor: 'private replies' stamp: 'DirkPorsche 6/17/2011 13:07'!
parseBulkReply
	| length reply |
	length := self parseInteger.
	length = -1
		ifTrue: [ reply := nil ]
		ifFalse: [ 
			reply := (stream next: length) asString.
			(stream upToAll: self binaryCrLf)].
	^ reply! !

!SSSRedisConnection methodsFor: 'private replies' stamp: 'DirkPorsche 6/17/2011 13:07'!
parseError
	SSSRedisError signal: (stream upToAll: self binaryCrLf) asString.
	^ nil! !

!SSSRedisConnection methodsFor: 'private replies' stamp: 'MLH 1/5/2010 22:32'!
parseInteger
	^self parseSingleLine asInteger! !

!SSSRedisConnection methodsFor: 'private replies' stamp: 'mlh 8/31/2010 20:58'!
parseMultiBulkReply
	| count reply |
	count := self parseInteger.
	count = -1
		ifTrue: [^ nil].
	reply := OrderedCollection new.
	count
		timesRepeat: [reply add: self parseReply].
	^ reply! !

!SSSRedisConnection methodsFor: 'private replies' stamp: 'DirkPorsche 6/16/2011 11:29'!
parseReply
	| replyToken |
	replyToken := Character value: stream next.
	replyToken = $+
		ifTrue: [^ self parseSingleLine].
	replyToken = $:
		ifTrue: [^ self parseInteger].
	replyToken = $$
		ifTrue: [^ self parseBulkReply].
	replyToken = $*
		ifTrue: [^ self parseMultiBulkReply].
	replyToken = $-
		ifTrue: [^ self parseError].
	SSSRedisError signal: 'Invalid Reply Token'
		! !

!SSSRedisConnection methodsFor: 'private replies' stamp: 'DirkPorsche 6/17/2011 13:05'!
parseSingleLine
	^(stream upToAll: self binaryCrLf) asString.
	! !

!SSSRedisConnection methodsFor: 'commands-connection' stamp: 'mlh 3/15/2011 14:33'!
ping
	^self unifiedCommand: {'PING'}.
	! !

!SSSRedisConnection methodsFor: 'accessing' stamp: 'MLH 1/5/2010 21:31'!
port
	^ port! !

!SSSRedisConnection methodsFor: 'accessing' stamp: 'MLH 1/5/2010 21:31'!
port: anObject
	port := anObject! !

!SSSRedisConnection methodsFor: 'commands-pubsub' stamp: 'DirkPorsche 6/16/2011 11:29'!
psubscribe: channels
	pubsub
		ifTrue: [ self unifiedCommand: {'PSUBSCRIBE'} , channels ]
		ifFalse: [ SSSRedisError signal: 'Not in pubsub mode, pass a callback block first.' ]! !

!SSSRedisConnection methodsFor: 'commands-pubsub' stamp: 'DirkPorsche 6/16/2011 11:29'!
psubscribe: channels callback: aBlock 
	pubsub
		ifTrue: [SSSRedisError signal: 'Already in pubsub mode. Unsubscribe first.']
		ifFalse: [self enterPubsub.
			self psubscribe: channels].
	self spawnReceiveProcess: aBlock! !

!SSSRedisConnection methodsFor: 'commands-pubsub' stamp: 'mlh 3/15/2011 15:42'!
publish: channel message: message
	^ self
		unifiedCommand:
			{'PUBLISH'.
			channel.
			message}! !

!SSSRedisConnection methodsFor: 'private' stamp: 'mlh 9/2/2010 13:58'!
pubsub
	^pubsub! !

!SSSRedisConnection methodsFor: 'commands-pubsub' stamp: 'mlh 3/15/2011 15:52'!
punsubscribe: channels
	self unifiedCommand: {'PUNSUBSCRIBE'} , channels! !

!SSSRedisConnection methodsFor: 'commands-connection' stamp: 'DirkPorsche 6/16/2011 11:15'!
quit
	stream
		nextPutAll: 'QUIT';
		crlf;
		flush.
	self disconnect! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 15:43'!
rPop: aKey
	^ self
		unifiedCommand:
			{'RPOP'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 14:35'!
rPoplPush: sourceKey to: destinationKey
	^ self
		unifiedCommand:
			{'RPOPLPUSH'.
			sourceKey.
			destinationKey}! !

!SSSRedisConnection methodsFor: 'commands-lists' stamp: 'mlh 3/15/2011 14:59'!
rPush: aKey value: aValue 
	^ self
		unifiedCommand: { 'RPUSH'
		. aKey
		. aValue}! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'MLH 1/6/2010 17:03'!
randomKey
	^ self inlineCommand: 'RANDOMKEY'! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'mlh 3/15/2011 15:49'!
rename: oldKey to: newKey
	^ self
		unifiedCommand:
			{'RENAME'.
			oldKey.
			newKey}! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'mlh 3/15/2011 15:49'!
renameNx: oldKey to: newKey
	^ self
		unifiedCommand:
			{'RENAMENX'.
			oldKey.
			newKey}! !

!SSSRedisConnection methodsFor: 'private replies' stamp: 'mlh 9/2/2010 13:40'!
reply
	^pubsub ifFalse: [ self parseReply ]! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:06'!
sAdd: aKey member: aMember
	^ self
		unifiedCommand:
			{'SADD'.
			aKey.
			aMember}! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:06'!
sCard: aKey
	^ self
		unifiedCommand:
			{'SCARD'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:06'!
sDiff: keys
	^ self unifiedCommand: {'SDIFF'} , keys! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:06'!
sDiffStore: destinationKey keys: keys
	^ self
		unifiedCommand:
			{'SDIFFSTORE'.
			destinationKey} , keys! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:06'!
sInter: keys
	^ self unifiedCommand: {'SINTER'} , keys! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:06'!
sInterStore: destinationKey keys: keys
	^ self
		unifiedCommand:
			{'SINTERSTORE'.
			destinationKey} , keys! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'DirkPorsche 6/14/2011 05:22'!
sIsMember: aKey member: aMember
	^ (self
		unifiedCommand:
			{'SISMEMBER'.
			aKey.
			aMember}) = 1! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:07'!
sMembers: aKey
	^ self
		unifiedCommand:
			{'SMEMBERS'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:07'!
sMove: sourceKey to: destinationKey member: aMember
	^ self
		unifiedCommand:
			{'SMOVE'.
			sourceKey.
			destinationKey.
			aMember}! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:08'!
sPop: aKey
	^ self
		unifiedCommand:
			{'SPOP'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:08'!
sRandMember: aKey
	^ self
		unifiedCommand:
			{'SRANDMEMBER'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:06'!
sRem: aKey member: aMember
	^ self
		unifiedCommand:
			{'SREM'.
			aKey.
			aMember}! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:08'!
sUnion: keys
	^ self unifiedCommand: {'SUNION'} , keys! !

!SSSRedisConnection methodsFor: 'commands-sets' stamp: 'mlh 3/15/2011 15:08'!
sUnionStore: destinationKey keys: keys
	^ self
		unifiedCommand:
			{'SUNIONSTORE'.
			destinationKey} , keys! !

!SSSRedisConnection methodsFor: 'commands-server' stamp: 'mlh 1/14/2010 21:41'!
save
	^ self inlineCommand: 'SAVE'! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'mlh 3/15/2011 15:46'!
select: zeroBasedDbIndex
	^ self
		unifiedCommand:
			{'SELECT'.
			zeroBasedDbIndex}! !

!SSSRedisConnection methodsFor: 'commands-strings' stamp: 'mlh 3/15/2011 15:41'!
set: aKey value: aValue
	^ self
		unifiedCommand:
			{'SET'.
			aKey.
			aValue}! !

!SSSRedisConnection methodsFor: 'commands-strings' stamp: 'mlh 3/15/2011 15:19'!
setNx: aKey value: aValue
	^ self
		unifiedCommand:
			{'SETNX'.
			aKey.
			aValue}! !

!SSSRedisConnection methodsFor: 'commands-server' stamp: 'DirkPorsche 6/16/2011 11:15'!
shutdown
	stream
		nextPutAll: 'SHUTDOWN';
		crlf;
		flush.
	self disconnect! !

!SSSRedisConnection methodsFor: 'commands-server' stamp: 'mlh 3/15/2011 15:33'!
slaveOf: host port: hostPort
	^ self
		unifiedCommand:
			{'SLAVEOF'.
			host.
			hostPort}! !

!SSSRedisConnection methodsFor: 'commands-sorting' stamp: 'mlh 3/15/2011 15:38'!
sort: aKey
	^ self
		unifiedCommand:
			{'SORT'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-sorting' stamp: 'mlh 3/15/2011 15:38'!
sort: aKey by: aPattern
	^ self
		unifiedCommand:
			{'SORT'.
			aKey.
			'BY'.
			aPattern}! !

!SSSRedisConnection methodsFor: 'commands-sorting' stamp: 'MLH 1/8/2010 10:41'!
sortQuery: aRedisSortQuery 
	^ aRedisSortQuery executeOn: self! !

!SSSRedisConnection methodsFor: 'private' stamp: 'mlh 9/3/2010 20:42'!
spawnReceiveProcess: aBlock 
	"The format of messages are different for subscribe vs. psubscribe.
	Redis returns 3 elements for subcribe, 4 for psubscribe, with the
	acutal matched channel. I'm putting the matched channel last, rather
	than third, so for the client, we will always get type, channel,
	message, then finally the actual matched channel or nil."
	listener := [[self pubsub]
		whileTrue: [| message |
			message := self parseReply.
			message size = 3
				ifTrue: [aBlock
						cull: (message at: 1)
						cull: (message at: 2)
						cull: (message at: 3)
						cull: nil]
				ifFalse: [aBlock
						cull: (message at: 1)
						cull: (message at: 2)
						cull: (message at: 4)
						cull: (message at: 3)].
			((message at: 1)
						= 'unsubscribe'
					and: [(message at: 3)
							= 0])
				ifTrue: [self exitPubsub]]] fork! !

!SSSRedisConnection methodsFor: 'commands-pubsub' stamp: 'DirkPorsche 6/16/2011 11:29'!
subscribe: channels
	pubsub
		ifTrue: [ self unifiedCommand: {'SUBSCRIBE'} , channels ]
		ifFalse: [ SSSRedisError signal: 'Not in pubsub mode, pass a callback block first.' ]! !

!SSSRedisConnection methodsFor: 'commands-pubsub' stamp: 'DirkPorsche 6/16/2011 11:29'!
subscribe: channels callback: aBlock 
	pubsub
		ifTrue: [SSSRedisError signal: 'Already in pubsub mode. Unsubscribe first.']
		ifFalse: [self enterPubsub.
			self subscribe: channels].
	self spawnReceiveProcess: aBlock! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'mlh 3/15/2011 15:47'!
ttl: aKey
	^ self
		unifiedCommand:
			{'TTL'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-generic' stamp: 'mlh 3/15/2011 14:45'!
type: aKey 
	^ self unifiedCommand: {'TYPE' . aKey}! !

!SSSRedisConnection methodsFor: 'private commands' stamp: 'DirkPorsche 6/17/2011 15:19'!
unifiedCommand: args
	stream
		nextPut: $*;
		nextPutAll: args size asString;
		crlf.
	args
		do: [ :ea | 
			| string |
			string := ea asString.
			stream
				nextPut: $$;
				nextPutAll: string byteSize asString;
				crlf;
				nextPutAll: string;
				crlf].
	stream flush.
	^ self reply! !

!SSSRedisConnection methodsFor: 'private' stamp: 'mlh 1/14/2010 21:30'!
unixEpoch
	"Answer the difference in seconds between the unix epoch and the
	squeak epoch"
	^ 2177452800! !

!SSSRedisConnection methodsFor: 'commands-pubsub' stamp: 'mlh 9/3/2010 08:29'!
unsubscribe
	self inlineCommand: 'UNSUBSCRIBE'.
	! !

!SSSRedisConnection methodsFor: 'commands-pubsub' stamp: 'mlh 3/15/2011 15:51'!
unsubscribe: channels
	self unifiedCommand: {'UNSUBSCRIBE'} , channels! !

!SSSRedisConnection methodsFor: 'commands-transactions' stamp: 'mlh 8/31/2010 20:41'!
unwatch
	^ self inlineCommand: 'UNWATCH'! !

!SSSRedisConnection methodsFor: 'accessing' stamp: 'bp 11/29/2014 21:55'!
version
	^self info readStream
		upTo: $:;
		upToAll: String crlf! !

!SSSRedisConnection methodsFor: 'commands-transactions' stamp: 'mlh 3/15/2011 16:08'!
watch: keys
	self unifiedCommand: {'WATCH'} , keys! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 3/15/2011 15:34'!
zAdd: aKey score: aScore member: aMember
	^ self
		unifiedCommand:
			{'ZADD'.
			aKey.
			aScore.
			aMember}! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 3/15/2011 15:34'!
zCard: aKey
	^ self
		unifiedCommand:
			{'ZCARD'.
			aKey}! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 3/15/2011 15:34'!
zIncrBy: aKey increment: anIncrement member: aMember
	^ self
		unifiedCommand:
			{'ZINCRBY'.
			aKey.
			anIncrement.
			aMember}! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 1/12/2010 19:20'!
zRange: aKey start: aStart end: anEnd 
	^ self
		zRange: aKey
		start: aStart
		end: anEnd
		includeScore: false! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 3/15/2011 15:35'!
zRange: aKey start: aStart end: anEnd includeScore: shouldIncludeScore
	| args |
	args := shouldIncludeScore
		ifTrue: [ 
			{aKey.
			aStart.
			anEnd.
			'WITHSCORES'} ]
		ifFalse: [ 
			{aKey.
			aStart.
			anEnd} ].
	^ self unifiedCommand: {'ZRANGE'} , args! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 3/15/2011 15:35'!
zRangeByScore: aKey min: aMin max: aMax
	^ self
		unifiedCommand:
			{'ZRANGEBYSCORE'.
			aKey.
			aMin.
			aMax}! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 3/15/2011 15:36'!
zRangeByScore: aKey min: aMin max: aMax offset: anOffset count: aCount
	^ self
		unifiedCommand:
			{'ZRANGEBYSCORE'.
			aKey.
			aMin.
			aMax.
			'LIMIT'.
			anOffset.
			aCount}! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 3/15/2011 15:36'!
zRem: aKey member: aMember
	^ self
		unifiedCommand:
			{'ZREM'.
			aKey.
			aMember}! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 3/15/2011 15:36'!
zRemRangeByRank: key start: start end: end
	^ self
		unifiedCommand:
			{'ZREMRANGEBYRANK'.
			key.
			start.
			end}! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 3/15/2011 15:37'!
zRemRangeByScore: key min: min max: max
	^ self
		unifiedCommand:
			{'ZREMRANGEBYSCORE'.
			key.
			min.
			max}! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 1/12/2010 19:20'!
zRevRange: aKey start: aStart end: anEnd 
	^ self
		zRevRange: aKey
		start: aStart
		end: anEnd
		includeScore: false! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 3/15/2011 15:37'!
zRevRange: aKey start: aStart end: anEnd includeScore: shouldIncludeScore
	| args |
	args := shouldIncludeScore
		ifTrue: [ 
			{aKey.
			aStart.
			anEnd.
			'WITHSCORES'} ]
		ifFalse: [ 
			{aKey.
			aStart.
			anEnd} ].
	^ self unifiedCommand: {'ZREVRANGE'} , args! !

!SSSRedisConnection methodsFor: 'commands-sorted-sets' stamp: 'mlh 3/15/2011 15:37'!
zScore: aKey element: anElement
	^ self
		unifiedCommand:
			{'ZSCORE'.
			aKey.
			anElement}! !

!SSSRedisConnection class methodsFor: 'instance-creation' stamp: 'MikeHales 1/18/2010 11:58'!
localhost
	^self server: '127.0.0.1' port: 6379! !

!SSSRedisConnection class methodsFor: 'instance-creation' stamp: 'mlh 9/2/2010 13:36'!
new
	^super new initialize! !

!SSSRedisConnection class methodsFor: 'instance-creation' stamp: 'MLH 1/5/2010 21:42'!
server: hostname port: portNumber 
	^ self new hostname: hostname;
		 port: portNumber;
		 connect;
		 yourself! !

!SSSRedisConnectionTest methodsFor: 'running' stamp: 'DirkPorsche 6/17/2011 19:54'!
setUp
	connection := SSSRedisConnection localhost.! !

!SSSRedisConnectionTest methodsFor: 'running' stamp: 'mlh 1/10/2010 12:02'!
tearDown
	connection isConnected
		ifTrue: [connection flushAll ; quit].
	connection := nil! !

!SSSRedisConnectionTest methodsFor: 'testing-transactions' stamp: 'mlh 8/31/2010 20:59'!
testAtomic
	connection atomic: [
	connection set: 'test' value: 'testValue'.
	connection set: 'test2' value: 'testValue2' ].
	self assert: (connection get: 'test')
			= 'testValue'.
	self assert: (connection get: 'test2')
			= 'testValue2'! !

!SSSRedisConnectionTest methodsFor: 'testing-transactions' stamp: 'mlh 8/31/2010 21:00'!
testAtomicWatch
	connection
		atomic: [connection set: 'test' value: 'testValue'.
			connection set: 'test2' value: 'testValue2'] watch: {'test'}.
	self assert: (connection get: 'test')
			= 'testValue'.
	self assert: (connection get: 'test2')
			= 'testValue2'! !

!SSSRedisConnectionTest methodsFor: 'testing-connection' stamp: 'mlh 1/9/2010 22:29'!
testAuth
	"This should pass if you enable the default authorization in your
	redis-server, else it should fail"
	self assert: (connection auth: 'foobared')
			= 'OK'! !

!SSSRedisConnectionTest methodsFor: 'testing-lists' stamp: 'DirkPorsche 6/17/2011 19:57'!
testBlPop
	self
		versionGreaterThan: '1.3.1'
		do: [| result |
			[
			SSSRedisConnection localhost lPush: 'test' value: 1] fork.
			result := connection blPop: {'test'} timeout: 10.
			self assert: result first = 'test'.
			self assert: result last = '1']! !

!SSSRedisConnectionTest methodsFor: 'testing-lists' stamp: 'DirkPorsche 6/17/2011 19:58'!
testBrPop
	self
		versionGreaterThan: '1.3.1'
		do: [| result |
			[SSSRedisConnection localhost lPush: 'test' value: 1] fork.
			result := connection brPop: {'test'} timeout: 10.
			self assert: result first = 'test'.
			self assert: result last = '1']! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 1/9/2010 22:40'!
testDbSize
	self assert: connection dbSize = 0.
	connection set: 'test' value: 15.
	self assert: connection dbSize = 1! !

!SSSRedisConnectionTest methodsFor: 'testing-strings' stamp: 'mlh 1/10/2010 15:40'!
testDecr
	connection set: 'test' value: '10'.
	connection decr: 'test'.
	self assert: ( connection get: 'test' ) = '9'! !

!SSSRedisConnectionTest methodsFor: 'testing-strings' stamp: 'mlh 1/10/2010 15:40'!
testDecrBy
	connection set: 'test' value: '10'.
	connection decr: 'test' by: 3.
	self assert: ( connection get: 'test' ) = '7'! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 1/9/2010 22:41'!
testDel
	
	connection set: 'test' value: 15.
	self assert: connection dbSize = 1.
	connection del: {'test'}.
	self assert: connection dbSize = 0! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 9/7/2010 15:42'!
testExists
	self deny: (connection exists: 'test').
	connection set: 'test' value: 15.
	self assert: (connection exists: 'test')
			! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 3/15/2011 16:07'!
testExpireAt
	| ttl | connection set: 'test' value: 'awesome'.
	self assert: (
			connection expire: 'test' at: DateAndTime now
					+ (Duration seconds: 120)) = 1.
	! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 9/7/2010 16:45'!
testExpireSeconds
	connection set: 'test' value: 20 .
	connection expire: 'test' seconds: 1.
	(Delay forSeconds: 2 ) wait.
	self deny: ( connection exists: 'test' ) 
	! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 9/7/2010 16:46'!
testFlushDb
	connection set: 'test' value: 20 .
	connection flushDb.
	self deny: ( connection exists: 'test' ) .
	! !

!SSSRedisConnectionTest methodsFor: 'testing-strings' stamp: 'mlh 1/10/2010 15:14'!
testGet
	connection set: 'test' value: 'testValue'.
	self assert: (connection get: 'test')
			= 'testValue'! !

!SSSRedisConnectionTest methodsFor: 'testing-strings' stamp: 'mlh 1/10/2010 15:39'!
testGetSet
	connection set: 'test' value: 'first'.
	self assert: (connection getSet: 'test' value: 'second' ) = 'first'.
	self assert: ( connection get: 'test' ) = 'second'! !

!SSSRedisConnectionTest methodsFor: 'testing-hashes' stamp: 'DirkPorsche 6/17/2011 19:59'!
testHDel
	self
		versionGreaterThan: '1.3'
		do: [connection del: 'testhash'.
			connection
				hSet: 'testhash'
				field: 'a'
				value: 'super'.
			self assert: (connection hExists: 'testhash' field: 'a').
			connection hDel: 'testhash' field: 'a'.
			self deny: (connection hExists: 'testhash' field: 'a')
					]! !

!SSSRedisConnectionTest methodsFor: 'testing-hashes' stamp: 'DirkPorsche 6/17/2011 19:59'!
testHExists
	self
		versionGreaterThan: '1.3'
		do: [connection del: 'testhash'.
			self
				deny: (connection hExists: 'testhash' field: 'a') .
			connection
				hSet: 'testhash'
				field: 'a'
				value: 'super'.
			self
				assert: (connection hExists: 'testhash' field: 'a') ]! !

!SSSRedisConnectionTest methodsFor: 'testing-hashes' stamp: 'DirkPorsche 6/17/2011 19:59'!
testHGet
	self
		versionGreaterThan: '1.3'
		do: [connection del: 'testhash'.
			connection
				hSet: 'testhash'
				field: 'a'
				value: 'super'.
			self assert: ( connection hGet: 'testhash' field: 'a' ) = 'super']! !

!SSSRedisConnectionTest methodsFor: 'testing-hashes' stamp: 'DirkPorsche 6/17/2011 20:00'!
testHGetAll
	self
		versionGreaterThan: '1.3'
		do: [| dict | 
			connection del: 'testhash'.
			connection
				hSet: 'testhash'
				field: 'a'
				value: 'super'.
			connection
				hSet: 'testhash'
				field: 'b'
				value: 'cool'.
			dict := connection hGetAll: 'testhash' .
			self assert: ( dict at: 'a') = 'super'.
			self assert: ( dict at: 'b' ) = 'cool'
					]! !

!SSSRedisConnectionTest methodsFor: 'testing-hashes' stamp: 'DirkPorsche 6/17/2011 20:00'!
testHIncrBy
	self
		versionGreaterThan: '1.3'
		do: [
			connection del: 'testhash'.
			connection
				hSet: 'testhash'
				field: 'a'
				value: '1'.
			connection
				hIncrBy: 'testhash'
				field: 'a'
				value: '2'.
			self assert: (connection hGet: 'testhash' field: 'a' ) = '3'.
			]! !

!SSSRedisConnectionTest methodsFor: 'testing-hashes' stamp: 'DirkPorsche 6/17/2011 20:00'!
testHKeys
	self
		versionGreaterThan: '1.3'
		do: [| keys |
			connection del: 'testhash'.
			connection
				hSet: 'testhash'
				field: 'a'
				value: '1'.
			connection
				hSet: 'testhash'
				field: 'b'
				value: '1'.
			keys := connection hKeys: 'testhash'.
			self assert: (keys first = 'a').
			self assert: ( keys last = 'b' )
					]! !

!SSSRedisConnectionTest methodsFor: 'testing-hashes' stamp: 'DirkPorsche 6/17/2011 20:00'!
testHLen
	self
		versionGreaterThan: '1.3'
		do: [connection del:  'testhash' .
			self assert: (connection hLen: 'testhash') = 0. 
			connection hSet: 'testhash' field: 'a' value: 'super'.
			self assert: ( connection hLen: 'testhash' )= 1]! !

!SSSRedisConnectionTest methodsFor: 'testing-hashes' stamp: 'DirkPorsche 6/17/2011 20:00'!
testHMGet
	self
		versionGreaterThan: '1.3'
		do: [| values |
			connection del: 'testhash'.
			connection
				hSet: 'testhash'
				field: 'a'
				value: '1'.
			connection
				hSet: 'testhash'
				field: 'b'
				value: '2'.
			connection hGetAll: 'testhash'.
			values := connection hMGet: 'testhash' fields: {'a'. 'b'}.
			self assert: values first = '1'.
			self assert: values last = '2']! !

!SSSRedisConnectionTest methodsFor: 'testing-hashes' stamp: 'DirkPorsche 6/17/2011 20:00'!
testHMSet
	self
		versionGreaterThan: '1.3'
		do: [| dict |
			connection del: 'testhash'.
			dict := Dictionary new.
			dict at: 'a' put: 'super'.
			dict at: 'b' put: 'cool'.
			connection hMSet: 'testhash' dictionary: dict.
			dict := connection hGetAll: 'testhash'.
			self assert: (dict at: 'a')
					= 'super'.
			self assert: (dict at: 'b')
					= 'cool']! !

!SSSRedisConnectionTest methodsFor: 'testing-hashes' stamp: 'DirkPorsche 6/17/2011 20:00'!
testHSet
	self
		versionGreaterThan: '1.3'
		do: [connection del: 'testhash'.
			connection
				hSet: 'testhash'
				field: 'a'
				value: 'super'.
			self assert: (connection hGet: 'testhash' field: 'a')
					= 'super']! !

!SSSRedisConnectionTest methodsFor: 'testing-hashes' stamp: 'DirkPorsche 6/17/2011 20:00'!
testHVals
	self
		versionGreaterThan: '1.3'
		do: [| values |
			connection del: 'testhash'.
			connection
				hSet: 'testhash'
				field: 'a'
				value: '1'.
			connection
				hSet: 'testhash'
				field: 'b'
				value: '2'.
			values := connection hVals: 'testhash'.
			self assert: values first = '1'.
			self assert: values last = '2']! !

!SSSRedisConnectionTest methodsFor: 'testing-strings' stamp: 'mlh 1/10/2010 15:42'!
testIncr
	connection set: 'test' value: '10'.
	connection incr: 'test'.
	self assert: ( connection get: 'test' ) = '11'! !

!SSSRedisConnectionTest methodsFor: 'testing-strings' stamp: 'mlh 1/10/2010 15:42'!
testIncrBy
	connection set: 'test' value: '10'.
	connection incr: 'test' by: 3.
	self assert: ( connection get: 'test' ) = '13'! !

!SSSRedisConnectionTest methodsFor: 'testing-connection' stamp: 'bp 11/29/2014 22:35'!
testInfo
	self assert: (connection info readStream upToAll: String crlf) = '# Server'! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 9/20/2010 21:22'!
testKeys
	| keys |
	connection set: 'test' value: 20 .
	connection set: 'test2' value: 10 .
	keys := connection keys: 'tes*'.
	self assert: keys first = 'test'.
	self assert: keys last = 'test2'! !

!SSSRedisConnectionTest methodsFor: 'testing-lists' stamp: 'mlh 1/10/2010 19:44'!
testLIndex
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 2.
	connection lPush: 'test' value: 3.
	connection lPush: 'test' value: 4.
	self assert: (connection lIndex: 'test' value: 1)
			= '3'! !

!SSSRedisConnectionTest methodsFor: 'testing-lists' stamp: 'mlh 1/10/2010 19:33'!
testLLen
	connection lPush: 'test' value: 1.
	self assert: (connection lLen: 'test')
			= 1! !

!SSSRedisConnectionTest methodsFor: 'testing-lists' stamp: 'mlh 1/10/2010 19:33'!
testLPop
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 2.
	self assert: (connection lPop: 'test')
			= '2'! !

!SSSRedisConnectionTest methodsFor: 'testing-lists' stamp: 'mlh 1/10/2010 19:51'!
testLRange
	"0-based index, most recent at lowest index (left)"
	| range |
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 2.
	connection lPush: 'test' value: 3.
	connection lPush: 'test' value: 4.
	range := connection
				lRange: 'test'
				start: 1
				end: 2.
	self assert: range first = '3'.
	self assert: range last = '2'! !

!SSSRedisConnectionTest methodsFor: 'testing-lists' stamp: 'mlh 1/10/2010 19:55'!
testLRem
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 4.
	connection
		lRem: 'test'
		count: 2
		value: 1.
	self assert: (connection lLen: 'test')
			= 2.
	self assert: (connection lPop: 'test')
			= '4'! !

!SSSRedisConnectionTest methodsFor: 'testing-lists' stamp: 'mlh 1/10/2010 19:57'!
testLSet
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 4.
	connection
		lSet: 'test'
		index: 2
		value: 2.
	self assert: (connection lIndex: 'test' value: 2)
			= '2'! !

!SSSRedisConnectionTest methodsFor: 'testing-lists' stamp: 'mlh 1/10/2010 19:58'!
testLTrim
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 1.
	connection lPush: 'test' value: 4.
	connection
		lTrim: 'test'
		start: 0
		end: 1.
	self assert: (connection lLen: 'test')
			= 2.
	self assert: (connection lPop: 'test')
			= '4'! !

!SSSRedisConnectionTest methodsFor: 'testing-strings' stamp: 'mlh 1/10/2010 15:21'!
testMGet
	| values |
	connection set: 'test' value: 'testValue'.
	connection set: 'test2' value: 'testValue2'.
	values := connection mGet: {'test'. 'test2'}.
	self assert: values first = 'testValue'.
	self assert: values second = 'testValue2'! !

!SSSRedisConnectionTest methodsFor: 'testing-strings' stamp: 'mlh 1/10/2010 21:18'!
testMSet
	self
		versionGreaterThan: '1.1'
		do: [| dict values |
			dict := Dictionary new.
			dict at: 'test' put: 'testValue';
				 at: 'test2' put: 'testValue2'.
			connection mSet: dict.
			values := connection mGet: {'test'. 'test2'}.
			self assert: values first = 'testValue'.
			self assert: values second = 'testValue2']! !

!SSSRedisConnectionTest methodsFor: 'testing-strings' stamp: 'DirkPorsche 6/17/2011 21:55'!
testMSetNx
	self
		versionGreaterThan: '1.1'
		do: [| dict values |
			connection set: 'test' value: 'original'.
			dict := Dictionary new.
			dict at: 'test' put: 'testValue';
				 at: 'test2' put: 'testValue2'.
			connection mSetNx: dict.
			values := connection mGet: {'test'. 'test2'}.
			self assert: values first = 'original'.
			self assert: values second = nil]! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 9/7/2010 16:45'!
testMoveTo
	connection set: 'test' value: 20.
	connection move: 'test' to: 1.
	connection select: 0.
	self deny: (connection exists: 'test')! !

!SSSRedisConnectionTest methodsFor: 'testing-transactions' stamp: 'mlh 8/31/2010 20:48'!
testMulti
	connection multi.
	self assert: (connection set: 'test' value: 'testValue') = 'QUEUED'.
	self assert: (connection set: 'test2' value: 'testValue2') = 'QUEUED'.
	connection exec.
	self assert: (connection get: 'test')
			= 'testValue'.
	self assert: (connection get: 'test2')
			= 'testValue2'! !

!SSSRedisConnectionTest methodsFor: 'testing-pubsub' stamp: 'DirkPorsche 6/17/2011 20:01'!
testPSubscribe
	| publisher semaphore message |
	semaphore := Semaphore new.
	connection
		psubscribe: 'x.*'
		callback: [:t :c :m :p | (message := m) = 'wow'
				ifTrue: [semaphore signal]].
	connection psubscribe: 'a.*'.
	publisher := SSSRedisConnection localhost.
	publisher publish: 'a.wesome' message: 'wow'.
	semaphore wait.
	self assert: message = 'wow'.
	connection unsubscribe! !

!SSSRedisConnectionTest methodsFor: 'testing-pubsub' stamp: 'DirkPorsche 6/17/2011 20:01'!
testPSubscribeCallback
	| publisher semaphore message |
	semaphore := Semaphore new.
	connection
		psubscribe: 'a.*'
		callback: [:t :c :m :p | (message := m) = 'wow'
				ifTrue: [semaphore signal]].
	publisher := SSSRedisConnection localhost.
	publisher publish: 'a.wesome' message: 'wow'.
	semaphore wait.
	self assert: message = 'wow'.
	connection unsubscribe! !

!SSSRedisConnectionTest methodsFor: 'testing-pubsub' stamp: 'DirkPorsche 6/17/2011 20:01'!
testPUnsubscribe
	| publisher semaphore message |
	semaphore := Semaphore new.
	connection
		subscribe: 'a'
		callback: [:t :c :m :p | (message := m) = 'wow'
				ifTrue: [semaphore signal]].
	connection psubscribe: 'b.*'.
	publisher := SSSRedisConnection localhost.
	publisher publish: 'a' message: 'wow'.
	semaphore wait.
	self assert: message = 'wow'.
	connection punsubscribe: 'b.*'.
	self assert: (publisher publish: 'b.ogus' message: 'great')
			= 0.
	connection unsubscribe! !

!SSSRedisConnectionTest methodsFor: 'testing-connection' stamp: 'mlh 1/8/2010 11:02'!
testQuit
	connection quit.
	self deny: connection isConnected! !

!SSSRedisConnectionTest methodsFor: 'testing-lists' stamp: 'mlh 1/10/2010 19:35'!
testRPop
	connection rPush: 'test' value: 1.
	connection rPush: 'test' value: 2.
	self assert: (connection rPop: 'test')
			= '2'! !

!SSSRedisConnectionTest methodsFor: 'testing-lists' stamp: 'mlh 1/10/2010 21:17'!
testRPopLPush
	self
		versionGreaterThan: '1.1'
		do: [connection lPush: 'source' value: 1.
			connection lPush: 'destination' value: 1.
			connection rPoplPush: 'source' to: 'destination'.
			self assert: (connection lLen: 'source')
					= 0.
			self assert: (connection lLen: 'destination')
					= 2]! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 1/10/2010 13:28'!
testRandomKey
	connection set: 'test' value: 20.
	connection set: 'rad' value: 10.
	connection set: 'awesome' value: 2.
	self
		assert: ({'test'. 'rad'. 'awesome'} includes: connection randomKey)! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 1/10/2010 13:24'!
testRename
	connection set: 'test' value: 'testVal'.
	connection rename: 'test' to: 'changed'.
	self assert: ( connection get: 'changed' ) = 'testVal'! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 1/10/2010 14:54'!
testRenameNx
	connection 
		set: 'test'
		value: 'testVal'.
	connection 
		renameNx: 'test'
		to: 'changed'.
	self assert: (connection get: 'changed') = 'testVal'.
	connection 
		set: 'test'
		value: 'testVal2'.
	self assert: (connection 
			renameNx: 'changed'
			to: 'test') = 0.
	self assert: (connection get: 'test') = 'testVal2'! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:20'!
testSAdd
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test' member: 'set2'.
	self assert: (connection sMembers: 'test') size = 2! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:24'!
testSCard
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test' member: 'set2'.
	self assert: (connection sCard: 'test') = 2! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:27'!
testSDiff
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test2' member: 'set1'.
	connection sAdd: 'test2' member: 'set2'.
	self assert: (connection sDiff: {'test2'. 'test'}) first = 'set2'! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:29'!
testSDiffStore
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test2' member: 'set1'.
	connection sAdd: 'test2' member: 'set2'.
	connection sDiffStore: 'test3' keys: {'test2'. 'test'}.
	self assert: ( connection sPop: 'test3' ) = 'set2'! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:30'!
testSInter
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test2' member: 'set1'.
	connection sAdd: 'test2' member: 'set2'.
	self assert: (connection sInter: {'test2'. 'test'}) first = 'set1'! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:30'!
testSInterStore
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test2' member: 'set1'.
	connection sAdd: 'test2' member: 'set2'.
	connection sInterStore: 'test3' keys: {'test2'. 'test'}.
	self assert: ( connection sPop: 'test3' ) = 'set1'! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'DirkPorsche 6/17/2011 20:02'!
testSIsMember
	connection sAdd: 'test' member: 'set1'.
	self assert: (connection sIsMember: 'test' member: 'set1' )! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:24'!
testSMembers
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test' member: 'set1'.
	self assert: (connection sMembers: 'test') size = 1! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:32'!
testSMove
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test2' member: 'set2'.
	connection sMove: 'test2' to: 'test' member: 'set2'.
	self assert: (connection sMembers: 'test') size = 2! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:36'!
testSRandMember
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test' member: 'set2'.
	self
		assert: ({'set1'. 'set2'}
				includes: (connection sRandMember: 'test'))! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:37'!
testSRemMember
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test' member: 'set2'.
	connection sRem: 'test' member: 'set1'.
	self assert: (connection sCard: 'test')
			= 1! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:33'!
testSUnion
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test2' member: 'set1'.
	connection sAdd: 'test2' member: 'set2'.
	self assert: (connection sUnion: {'test2'. 'test'}) size = 2! !

!SSSRedisConnectionTest methodsFor: 'testing-sets' stamp: 'mlh 1/11/2010 21:34'!
testSUnionStore
	connection sAdd: 'test' member: 'set1'.
	connection sAdd: 'test2' member: 'set1'.
	connection sAdd: 'test2' member: 'set2'.
	connection sUnionStore: 'test3' keys: {'test2'. 'test'}.
	self assert: ( connection sCard: 'test3' ) = 2! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 9/7/2010 16:45'!
testSelect
	connection set: 'test' value: 20.
	connection move: 'test' to: 1.
	connection select: 1.
	self assert: (connection exists: 'test')! !

!SSSRedisConnectionTest methodsFor: 'testing-strings' stamp: 'mlh 1/10/2010 15:30'!
testSetNx
	connection set: 'test' value: 'testValue'.
	connection setNx: 'test2' value: 'testValue2'.
	connection setNx: 'test' value: 'overwritten'.
	self assert: (connection get: 'test')
			= 'testValue'.
	self assert: (connection get: 'test2')
			= 'testValue2'! !

!SSSRedisConnectionTest methodsFor: 'testing-sorting' stamp: 'mlh 1/12/2010 19:33'!
testSort
	| results |
	connection lPush: 'test' value: 4;
		 lPush: 'test' value: 2;
		 lPush: 'test' value: 8.
	results := connection sort: 'test'.
	self assert: results size = 3.
	self assert: results first = '2'.
	self assert: results last = '8'! !

!SSSRedisConnectionTest methodsFor: 'testing-sorting' stamp: 'mlh 1/12/2010 20:13'!
testSortBy
	| results |
	connection lPush: 'users' value: 'joe';
		 lPush: 'users' value: 'mike';
		 lPush: 'users' value: 'fred'.
	connection set: 'weight:joe' value: 145.
	connection set: 'weight:mike' value: 190.
	connection set: 'weight:fred' value: 165.
	results := connection sort: 'users' by: 'weight:*'.
	self assert: results first = 'joe'.
	self assert: results last = 'mike'! !

!SSSRedisConnectionTest methodsFor: 'testing-pubsub' stamp: 'DirkPorsche 6/17/2011 20:02'!
testSubscribe
	| publisher semaphore message |
	semaphore := Semaphore new.
	connection
		subscribe: 'x'
		callback: [:t :c :m | (message := m) = 'wow'
				ifTrue: [semaphore signal]].
	connection subscribe: 'a'.
	publisher := SSSRedisConnection localhost.
	publisher publish: 'a' message: 'wow'.
	semaphore wait.
	self assert: message = 'wow'.
	connection unsubscribe! !

!SSSRedisConnectionTest methodsFor: 'testing-pubsub' stamp: 'DirkPorsche 6/17/2011 20:02'!
testSubscribeCallback
	| publisher semaphore message |
	semaphore := Semaphore new.
	connection
		subscribe: 'a'
		callback: [:t :c :m | (message := m) = 'wow'
				ifTrue: [semaphore signal]].
	publisher := SSSRedisConnection localhost.
	publisher publish: 'a' message: 'wow'.
	semaphore wait.
	self assert: message = 'wow'.
	connection unsubscribe.! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 1/10/2010 14:57'!
testTtl
	connection set: 'test' value: 20 .
	connection expire: 'test' seconds: 20.
	self assert: ( connection ttl: 'test' ) > 19 .
	! !

!SSSRedisConnectionTest methodsFor: 'testing-generic' stamp: 'mlh 1/10/2010 15:05'!
testType
	connection set: 'test' value: 'testString'.
	self assert: (connection type: 'test')
			= 'string'.
	connection lPush: 'list' value: 'first'.
	self assert: (connection type: 'list')
			= 'list'.
	connection sAdd: 'set' member: 'member'.
	self assert: (connection type: 'set')
			= 'set'.
	connection
		zAdd: 'sortedSet'
		score: 1
		member: 'member'.
	self assert: (connection type: 'sortedSet')
			= 'zset'! !

!SSSRedisConnectionTest methodsFor: 'testing-pubsub' stamp: 'DirkPorsche 6/17/2011 20:02'!
testUnsubscribe
	| publisher semaphore message |
	semaphore := Semaphore new.
	connection
		subscribe: 'a'
		callback: [:t :c :m :p | (message := m) = 'wow'
				ifTrue: [semaphore signal]].
	connection subscribe: 'b'.
	publisher := SSSRedisConnection localhost.
	publisher publish: 'a' message: 'wow'.
	semaphore wait.
	self assert: message = 'wow'.
	connection unsubscribe: 'b'.
	self assert: (publisher publish: 'b' message: 'great')
			= 0.
	connection unsubscribe! !

!SSSRedisConnectionTest methodsFor: 'testing-transactions' stamp: 'mlh 8/31/2010 20:57'!
testWatch
	connection watch: { 'test' }.
	connection multi.
	self assert: (connection set: 'test' value: 'testValue')
			= 'QUEUED'.
	self assert: (connection set: 'test2' value: 'testValue2')
			= 'QUEUED'.
	connection exec.
	self assert: (connection get: 'test')
			= 'testValue'.
	self assert: (connection get: 'test2')
			= 'testValue2'! !

!SSSRedisConnectionTest methodsFor: 'testing-sorted-sets' stamp: 'mlh 1/12/2010 23:34'!
testZAddScoreMember
	self
		versionGreaterThan: '1.1'
		do: [connection
				zAdd: 'test'
				score: 1
				member: 'first'.
			connection
				zAdd: 'test'
				score: 2
				member: 'second'.
			self assert: (connection
					zRangeByScore: 'test'
					min: 1
					max: 2) size = 2]! !

!SSSRedisConnectionTest methodsFor: 'testing-sorted-sets' stamp: 'mlh 1/12/2010 23:34'!
testZCard
	self
		versionGreaterThan: '1.1'
		do: [connection
				zAdd: 'test'
				score: 1
				member: 'first'.
			connection
				zAdd: 'test'
				score: 2
				member: 'second'.
			self assert: (connection zCard: 'test')
					= 2]! !

!SSSRedisConnectionTest methodsFor: 'testing-sorted-sets' stamp: 'mlh 1/12/2010 23:35'!
testZIncrByIncrementMember
	self
		versionGreaterThan: '1.1'
		do: [connection
				zAdd: 'test'
				score: 1
				member: 'first'.
			connection
				zAdd: 'test'
				score: 2
				member: 'second'.
			connection
				zIncrBy: 'test'
				increment: 2
				member: 'first'.
			self assert: (connection
					zRangeByScore: 'test'
					min: 2
					max: 3) first = 'second']! !

!SSSRedisConnectionTest methodsFor: 'testing-sorted-sets' stamp: 'mlh 1/12/2010 23:35'!
testZRangeByScoreMinMax
	self
		versionGreaterThan: '1.1'
		do: [1
				to: 10
				do: [:idx | connection
						zAdd: 'test'
						score: idx
						member: idx].
			self assert: (connection
					zRangeByScore: 'test'
					min: 2
					max: 6) size = 5]! !

!SSSRedisConnectionTest methodsFor: 'testing-sorted-sets' stamp: 'mlh 1/12/2010 23:36'!
testZRangeByScoreMinMaxOffsetCount
	self
		versionGreaterThan: '1.1'
		do: [| results |
			1
				to: 10
				do: [:idx | connection
						zAdd: 'test'
						score: idx
						member: idx].
			results := connection
						zRangeByScore: 'test'
						min: 2
						max: 6
						offset: 2
						count: 3.
			self assert: results size = 3.
			self assert: results first = '4']! !

!SSSRedisConnectionTest methodsFor: 'testing-sorted-sets' stamp: 'mlh 1/12/2010 23:36'!
testZRangeStartEnd
	self
		versionGreaterThan: '1.1'
		do: [1
				to: 10
				do: [:idx | connection
						zAdd: 'test'
						score: idx
						member: idx].
			self assert: (connection
					zRange: 'test'
					start: 2
					end: 6) size = 5]! !

!SSSRedisConnectionTest methodsFor: 'testing-sorted-sets' stamp: 'mlh 1/12/2010 23:37'!
testZRangeStartEndIncludeScore
	self
		versionGreaterThan: '1.1'
		do: [1
				to: 10
				do: [:idx | connection
						zAdd: 'test'
						score: idx
						member: idx].
			self assert: (connection
					zRange: 'test'
					start: 2
					end: 6
					includeScore: true) size = 10]! !

!SSSRedisConnectionTest methodsFor: 'testing-sorted-sets' stamp: 'mlh 1/12/2010 23:37'!
testZRemMember
	self
		versionGreaterThan: '1.1'
		do: [1
				to: 10
				do: [:idx | connection
						zAdd: 'test'
						score: idx
						member: idx].
			connection zRem: 'test' member: 4.
			self assert: (connection zCard: 'test')
					= 9]! !

!SSSRedisConnectionTest methodsFor: 'testing-sorted-sets' stamp: 'mlh 1/12/2010 23:37'!
testZRevRangeStartEnd
	self
		versionGreaterThan: '1.1'
		do: [| results |
			1
				to: 10
				do: [:idx | connection
						zAdd: 'test'
						score: idx
						member: idx].
			self assert: (results := connection
							zRevRange: 'test'
							start: 2
							end: 6) size = 5.
			self assert: results first = '8']! !

!SSSRedisConnectionTest methodsFor: 'testing-sorted-sets' stamp: 'mlh 1/12/2010 23:38'!
testZRevRangeStartEndIncludeScores
	self
		versionGreaterThan: '1.1'
		do: [| results |
			1
				to: 10
				do: [:idx | connection
						zAdd: 'test'
						score: idx
						member: idx].
			self assert: (results := connection
							zRevRange: 'test'
							start: 2
							end: 6
							includeScore: true) size = 10.
			self assert: results first = '8']! !

!SSSRedisConnectionTest methodsFor: 'testing-sorted-sets' stamp: 'mlh 1/12/2010 23:38'!
testZScoreElement
	self
		versionGreaterThan: '1.1'
		do: [1
				to: 10
				do: [:idx | connection
						zAdd: 'test'
						score: idx
						member: idx].
			self assert: (connection zScore: 'test' element: '4')
					= '4']! !

!SSSRedisConnectionTest methodsFor: 'redis-version-support' stamp: 'bp 11/29/2014 21:59'!
version
	^connection version! !

!SSSRedisConnectionTest methodsFor: 'redis-version-support' stamp: 'mlh 1/10/2010 21:12'!
versionGreaterThan: aVersionString do: aBlock 
	self version > aVersionString
		ifTrue: [aBlock value]
		ifFalse: [self signalFailure: 'Installed Redis version does not support this command']! !
