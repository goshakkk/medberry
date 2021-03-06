var IdentityMixin = Ember.Mixin.create({
  firstName: DS.attr('string'),
  lastName: DS.attr('string'),
  status: DS.attr('string'),

  avatarUrl: '/assets/no-avatar.png',

  isOnline: Ember.computed.equal('status', 'online'),
  isOffline: Ember.computed.equal('status', 'offline'),

  fullName: function() {
    return [this.get('firstName'), this.get('lastName')].join(' ')
  }.property('firstName', 'lastName')
});

export default IdentityMixin;
