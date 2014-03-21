var send = function(self, eventName) {
  return function() {
    var newArguments = [eventName].concat(Array.prototype.slice.call(arguments, 0));
    Ember.run(function() {
      self.send.apply(self, newArguments)
    });
  };
};

var listenFor = function(object, self, eventName) {
  object.addEventListener(eventName, send(self, eventName))
};

var listenTo = function(object, self, events) {
  events.forEach(function(eventName) {
    listenFor(object, self, eventName);
  });
};

var publisherEvents = ['accessAllowed', 'accessDenied', 'accessDialogOpened', 'accessDialogClosed'];
var sessionEvents = ['connectionCreated', 'connectionDestroyed', 'sessionConnected', 'sessionDisconnected', 'signal', 'streamCreated', 'streamDestroyed', 'streamPropertyChanged'];

var selfId = 'video-self';
var selfSel = '#video-self';
var mateId = 'video-mate';
var mateSel = '#video-mate';

App.TokboxVideoComponent = Ember.Component.extend({
  sessionId: null, // tokbox session id
  token: null, // tokbox token
  publisher: null, // TB.Publisher
  session: null, // TB.Session
  cameraAccessError: null, // was there an error?
  selfPosition: 4, // 1 - top left, 2 - top right, 3 - bottom left, 4 - bottom right

  mateStreamId: null, // id of mate stream

  mate$: function() {
    return this.$(mateSel);
  },

  self$: function() {
    return this.$(selfSel);
  },

  setupEventListeners: function() {
    listenTo(this.publisher, this, publisherEvents);
    listenTo(this.session, this, sessionEvents);
  },

  setupTokbox: function() {
    var apiKey = tokboxApiKey,
        sessionId = this.get('sessionId'),
        token = this.get('token');

    this.setVideoSizes();
    this.positionVideoElements();

    this.publisher = TB.initPublisher(apiKey, selfId);
    this.session = TB.initSession(sessionId);

    this.setupEventListeners();

    this.session.connect(apiKey, token);
  }.on('didInsertElement'),

  computeOptimalMateVideoSize: function() {
    var vpWidth = this.$().width();
    var vpHeight = $(window).height() - this.$().offset().top - 100;

    var vpCandidate1 = { width: vpWidth, height: vpWidth * 3 / 4 };
    var vpCandidate2 = { height: vpHeight, width: vpHeight * 4 / 3 };

    return vpCandidate1.height > vpHeight ? vpCandidate2 : vpCandidate1;
  },

  setMateSize: function(size) {
    var mate$ = this.mate$();

    this.mateWidth = size.width;
    this.mateHeight = size.height;

    mate$.css(size);
  },

  setSelfSize: function(size) {
    var self$ = this.self$();

    this.selfWidth = size.width;
    this.selfHeight = size.height;

    self$.css(size);
  },

  getMateSize: function() {
    var mate$ = this.mate$();

    return { width: mate$.width(), height: mate$.height() };
  },

  setVideoSizes: function() {
    var mateSize = this.computeOptimalMateVideoSize();
    this.setMateSize(mateSize);

    var selfSize = { width: 264, height: 198 };
    this.setSelfSize(selfSize);
  },

  computeSelfVideoPosition: function() {
    var pos = parseInt(this.get('selfPosition'));

    var mate$ = this.mate$();
    var self$ = this.self$();
    var k = 20;

    var left = pos == 1 || pos == 3 ? k : mate$.width() - self$.width() - k;
    var top = pos == 1 || pos == 2 ? k : mate$.height() - self$.height() - k;

    return { left: left, top: top };
  },

  computeMateVideoPosition: function() {
    return { top: -this.self$().height() };
  },

  positionVideoElements: function() {
    var mate$ = this.mate$();
    var self$ = this.self$();

    mate$.css({ position: 'relative' });
    self$.css({ position: 'relative', 'z-index': 100 });

    var matePosition = this.computeMateVideoPosition();
    var selfPosition = this.computeSelfVideoPosition();

    mate$.css(matePosition);
    self$.css(selfPosition);
  },

  unsubscribeTokbox: function() {
    this.session.disconnect();
  }.on('willDestroyElement'),

  subscribeToStreams: function(streams) {
    var selfConnectionId = this.session.connection.connectionId;

    var notOwnStream = function(stream) {
      return stream.connection.connectionId != selfConnectionId;
    };

    var mateStream = this.session.streams.find(notOwnStream);

    if (mateStream && this.mateStreamId != mateStream.streamId) {
      this.session.subscribe(mateStream, mateId, this.getMateSize());
    }
  },

  publish: function() {
    this.session.publish(this.publisher);
  },

  actions: {
    accessDenied: function() {
      this.set('cameraAccessError', true);
    },

    sessionConnected: function(event) {
      this.subscribeToStreams(event.streams);
      this.publish();
    },

    streamCreated: function(event) {
      this.subscribeToStreams(event.streams);
    }
  }
});
