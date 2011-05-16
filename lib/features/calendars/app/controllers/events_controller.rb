class EventsController < ApplicationController
  def index
    @calendar = Calendar.find(params[:calendar_id])
    if @calendar.can_list?(current_user)
      @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
      case params[:period]
      when "day"
        @events = {@date.to_s => @calendar.events_at_date(@date)}
      when "week"
        @events = @calendar.events_at_period(
          :start_date => @date.beginning_of_week,
          :end_date => @date.end_of_week
        )
      when "month"
        @events = @calendar.events_at_period(
          :start_date => @date.beginning_of_month.beginning_of_week,
          :end_date => @date.end_of_month.end_of_week
        )
      end

      @period = params[:period]
      respond_to do |format|
        format.js
      end
    else
      render :nothing => true
    end
  end

  def show
    @event = Event.find(params[:id])
    @calendar = @event.calendar
    return false unless @calendar.can_view?(current_user)
    respond_to do |format|
      format.js
    end
  end

  def new
    @calendar = Calendar.find(params[:calendar_id])
    return false unless @calendar.can_add?(current_user)
    @event = Event.new
    @alarm = Alarm.new
    @categories = EventCategory.find_all_accessible(@calendar)
    @event.title = "Nouvel événement"
    @event.start_at = Date.parse(params[:date]).to_datetime + params[:top].to_i.minutes
    @event.end_at = @event.start_at + (params[:height].to_i).minutes
    respond_to do |format|
      format.js
    end
  end

  def create
    @calendar = Calendar.find(params[:calendar_id])
    return false unless @calendar.can_add?(current_user)
    
    params[:event][:by_day] = [params[:event].delete(:by_month_day_num) + params[:event].delete(:by_month_day_wday)] if params[:event][:by_month_day_num] && params[:event][:by_month_day_wday]
    @event = Event.new({ :calendar_id => @calendar.id }.merge(params[:event]))
    @event.alarms.build(params[:alarm])
    
    ## TODO participants management should be reviewed
    #params[:participants][:delete] ||= []
    #params[:participants][:delete].each do |p|
    #  Participant.find(p).destroy if @event.participant_ids.include?(p.to_i)
    #end
    #params[:participants][:new] ||= []
    #params[:participants][:new].each do |p|
    #  participant_index = params[:participants][:new].index(p)
    #  emp_id = params[:participants][:new_id][:participant_index]
    #  participant_option = Participant.parse(p)
    #  participant_option[:employee_id] = emp_id
    #  @event.participants << Participant.create(participant_option)
    #end
    
    @event.save! # TODO we should display an error message if failed
    
    respond_to do |format|
      format.js
    end   
  end

  def edit
    @event = Event.find(params[:id])
    @calendar = @event.calendar
    return false unless @calendar.can_edit?(current_user)
    @alarm = @event.alarms.first
    @categories = EventCategory.find_all_accessible(@calendar)
    respond_to do |format|
      format.js
    end
  end

  def update
    @event = Event.find(params[:id])
    return false unless @event.calendar.can_edit?(current_user)
    date = Date.parse(params[:date])
    exdate = Date.parse(params[:exdate]) if params[:exdate]

    if params[:delete]
      case params[:recur]
      when 'only'
        unless @event.exception_dates.include?(date)
          @event.exception_dates << ExceptionDate.create(:date => date) 
        end
      when 'future'
        @event.until_date = date - 1.day
      end
      if @event.start_at.to_date == date
        @event.destroy
      else
        @event.save        
      end
      return
    end

    case params[:recur]
    when 'only'
      unless @event.exception_dates.include?(exdate)
        @event.exception_dates << ExceptionDate.create(:date => exdate) 
      end
      event_attr_copy = @event.attributes
      ['frequence', 'until_date', 'count', 'by_day', 'by_month_day', 'by_month'].each do |key|
        event_attr_copy[key] = nil
      end
      event_attr_copy['interval'] = 1
      if params[:event]
        tmp_start_at = params[:event][:start_at].to_datetime
        tmp_end_at = params[:event][:end_at].to_datetime
        event_attr_copy['start_at'] = date + tmp_start_at.hour.hours + tmp_end_at.to_datetime.min.minutes
        event_attr_copy['end_at'] = date + tmp_end_at.hour.hours + tmp_end_at.min.minutes
      else
        event_attr_copy['start_at'] = date + event_attr_copy['start_at'].to_datetime.hour.hours + event_attr_copy['start_at'].to_datetime.min.minutes
        event_attr_copy['end_at'] = date + event_attr_copy['end_at'].to_datetime.hour.hours + event_attr_copy['end_at'].to_datetime.min.minutes
      end

      @event = Event.create(event_attr_copy)
    when 'future'
      unless @event.start_at.to_date == date
        event_copy = Event.create(@event.attributes)
        @event.until_date = exdate - 1.day
        @event.save
        @event = event_copy
      end
    end

    if params[:event]
      params[:event][:by_day] = [params[:event].delete(:by_day_num) + params[:event].delete(:by_day_wday)] if params[:event][:by_day_num] && params[:event][:by_day_wday]
      ['until_date', 'count', 'by_day', 'by_month_day', 'by_month'].each do |key|
        params[:event][key] ||= nil
      end

      if !params[:recur].blank?
        ['start_at', 'end_at', 'frequence', 'until_date', 'count', 'by_day', 'by_month_day', 'by_month'].each do |key|
          params[:event].delete(key)
        end
      end

      if params[:alarm]
        @alarm = Alarm.new(params[:alarm])
        @event.alarms[0] = @alarm
      end
      
      params[:participants][:delete] ||= []
      params[:participants][:delete].each do |p|
        Participant.find(p).destroy if @event.participant_ids.include?(p.to_i)
      end
      params[:participants][:new] ||= []
      params[:participants][:new].each do |p|
        participant_index = params[:participants][:new].index(p)
        emp_id = params[:participants][:new_id][participant_index]
        participant_option = Participant.parse(p)
        participant_option[:employee_id] = emp_id
        @event.participants << Participant.create(participant_option)
      end
      
      if @event.update_attributes(params[:event])
        @message = "Modification effectué avec succès"
      else
        @message = "Erreur lors de la modification"
      end
    else
      if params[:top].nil? && params[:height].nil?
        @event.start_at = date.to_datetime + @event.start_at.hour.hours + @event.end_at.min.minutes
        @event.end_at = date.to_datetime + @event.end_at.hour.hours + @event.end_at.min.minutes
      else
        @event.start_at = date.to_datetime + params[:top].to_i.minutes
        @event.end_at = @event.start_at + (params[:height].to_i).minutes 
      end
      if @event.save
        @message = "true"
      else
        @message = "false"
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @event = Event.find(params[:id])
    return false unless @event.calendar.can_delete?(current_user)
    @event.destroy

    respond_to do |format|
      format.js
    end
  end
end
