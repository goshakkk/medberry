var HistoryRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('consultation_request');
  }
});

export default HistoryRoute;
