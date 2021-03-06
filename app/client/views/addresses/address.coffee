exports = this


Template.addressItem.created = ->
  # Fix bug with ZeroClipboard
  Session.set "cancelMouseLeave", false


Template.addressItem.rendered = ->
  # Set top3 coins
  $(".address").slice(0,3).addClass "top_coin"
  $(".address:eq(0)").addClass "first is_active_top"
  $(".address:eq(1)").addClass "second"
  $(".address:eq(2)").addClass "third"

  # Truncate function
  truncate = (elem, fieldWidth, position) ->
    elem.truncate
      width: fieldWidth
      token: "..."
      side: position
      multiline: false

  # Truncate address
  $addressTitle = $(this.find ".address_title")
  $coinAddress = $addressTitle.find ".coin_address"
  $addressTitle.parents(".address").find(".show_address").
    data "truncated", $coinAddress.text()

  # Truncate balance
  $coinBalance = $(this.find ".coin_balance")
  $coinValue = $coinBalance.find ".coin_value"
  coinBalanceWidth = $coinBalance.width()
  nameWidth = $coinBalance.find(".coin_name").width()
  valueWidth = coinBalanceWidth - nameWidth
  # TODO: Investigate this 10px issue
  truncate $coinValue, valueWidth - 10, "right"


Template.addressItem.events
  # Click on element in functional panel
  "click .func_panel i": (e) ->
    e.preventDefault()
    $this = $(e.target)
    $addressCard = $this.parents ".address"
    $addressTitle =  $addressCard.find ".address_title"
    $addressValue = $addressCard.find ".coin_address"
    actualAddress = $addressCard.find(".copy").data "clipboard-text"

    ###
    On destop version it will be replaced with swf object,
    so there are no reason to check for mobile
    ###
    if $this.hasClass "copy"
      $mobileCopy = $(".mobile_copy")
      $textarea = $(".mobile_copy").find "textarea"
      $mobileCopy.addClass "is_active"
      $textarea.text(actualAddress).select()

    # Show/Hide full address
    if $this.hasClass "show_address"
      message = "Read your address below"
      $addressTitle.toggleClass "is_full"
      if $addressTitle.hasClass "is_full"
        $addressValue.text actualAddress
        $addressCard.find(".tip").text message
      else
        $addressValue.text $this.data "truncated"

    # Remove address
    if $this.hasClass "remove"
      if confirm "Delete this address?"
        actualAddress = $this.parents(".address").find(".copy").
          data "clipboard-text"
        name = $this.parents(".address").find(".coin_name").text()
        data =
            address: actualAddress
            name: name

        Meteor.call "removeAddress", data, (error, id) ->
          if error
            # Display the error
            Errors.throw error.reason

  # Hover on element in functional panel
  "mouseenter .func_panel i": (e) ->
    e.preventDefault()
    $this = $(e.target)
    if $this.hasClass "copy"
      message = "Copy address to clipboard"
    else if $this.hasClass "show_address"
      message = "Show/Hide full address"
    else if $this.hasClass "remove"
      message = "Remove this address"
    $this.parents(".address").find(".tip").text message

  # Hover on any address card
  "mouseenter .address": (e) ->
    e.preventDefault()
    $this = $(e.target)
    $this.addClass "is_active"
    Meteor.clearInterval timer
    Session.set "notification", "Price updates halted"

  "mouseenter .copy": (e) ->
    e.preventDefault()
    Session.set "cancelMouseLeave", true

  "mouseleave .is_active": (e) ->
    e.preventDefault()
    if not Session.get "cancelMouseLeave"
      exports.timer = Meteor.setInterval callApis, counter
      Session.set "notification", "Price updates resumed"
      $this = $(e.target)
      $(".address.is_active").removeClass "is_active"
    else
      Session.set "cancelMouseLeave", false
