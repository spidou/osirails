class EventsController < ApplicationController
  before_filter :check

  def index
    @calendar = Calendar.find(params[:calendar_id])
    @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    case params[:period]
    when "day"
      @start_date = @date
      @events = [@calendar.events_at_date(@start_date)]
    when "week"
      @start_date = @date.beginning_of_week
      @events = @calendar.events_at_period(:start_date => @start_date, :end_date => @date.end_of_week)
    when "month"
      @start_date = @date.beginning_of_month
      @events = @calendar.events_at_period(:start_date => @start_date, :end_date => @date.end_of_month)
    end

    @period = params[:period]
    respond_to do |format|
      format.js
    end
  end

  def show
    @calendar = Calendar.find(params[:calendar_id])
    @event = Event.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def new
    @calendar = Calendar.find(params[:calendar_id])
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
    params[:event][:by_day] = [params[:event].delete(:by_month_day_num) + params[:event].delete(:by_month_day_wday)] if params[:event][:by_month_day_num] && params[:event][:by_month_day_wday]
    @event = Event.create(params[:event])
    @event.alarms << Alarm.create(params[:alarm])
    @calendar.events << @event
    respond_to do |format|
      format.js
    end   
  end

  def edit
    @calendar = Calendar.find(params[:calendar_id])
    @event = Event.find(params[:id])
    @alarm = @event.alarms.first
    @categories = EventCategory.find_all_accessible(@calendar)
    respond_to do |format|
      format.js
    end
  end

  def update
    @event = Event.find(params[:id])
    date = params[:date].to_datetime

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
      unless @event.exception_dates.include?(date)
        @event.exception_dates << ExceptionDate.create(:date => date) 
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
        @event.until_date = date - 1.day
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
        @event.alarms.first = @alarm
      end

      if @event.update_attributes(params[:event])
        @message = "Modification effectué avec succès"
      else
        @message = "Erreur lors de la modification"
      end
      respond_to do |format|
        format.js
      end
    else
      @event.start_at = Date.parse(params[:date]).to_datetime + params[:top].to_i.minutes
      @event.end_at = @event.start_at + (params[:height].to_i).minutes 

      if @event.save
        render :text => "true"
      else
        render :text => "false"
      end
    end
  end

  def destroy
    @event = Event.find(params[:id])    
    @event.destroy

    respond_to do |format|
      format.js
    end
  end

  protected
    def check
      # TODO Verify if the current user have the authorization on the calendar and event
    end
end