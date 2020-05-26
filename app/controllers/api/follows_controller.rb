class Api::FollowsController < ApplicationController
  def index
  end

  def show
  end

  def create
  end

  def fetch_follows_data
    infos = []
    datetime = DateTime.current
    datetime = datetime.beginning_of_day
    channel_id = current_user.target_channel
    follower_info = {
      name: "全友だち数",
      data: {}
    }
    unblock_info = {
      name: "有効友だち数",
      data: {}
    }
    block_info = {
      name: "ブロック数",
      data: {}
    }
    case params[:timeOption]
    when "oneWeek"
      follows = Follow.where(channel_id: channel_id, date: ((datetime-7)..(datetime))).order("date")
      follows.each do |follow|
        date = follow.date
        follower_info[:data][date.strftime("%m/%d")] = follow.follower
        unblock_info[:data][date.strftime("%m/%d")] = follow.targetedReaches
        block_info[:data][date.strftime("%m/%d")] = follow.blocks
      end
      # infos.push(follower_info)
      # infos.push(unblock_info)
      # infos.push(block_info)
    when "oneMonth"
      follows = Follow.where(channel_id: channel_id, date: ((datetime-30)..(datetime-1))).order("date")
      follows.each do |follow|
        date = follow.date
        if date.wday == 6
          if date.day<=7
            title = date.month.to_s+"月1週"
          elsif date.day>7&&date.day<=14
            title = date.month.to_s+"月2週"
          elsif date.day>14&&date.day<=21
            title = date.month.to_s+"月3週"
          elsif date.day>21&&date.day<=28
            title = date.month.to_s+"月4週"
          elsif date.day>28&&date.day<=35
            title = date.month.to_s+"月5週"
          end
          follower_info[:data][title] = follow.follower
          unblock_info[:data][title] = follow.targetedReaches
          block_info[:data][title] = follow.blocks
        end
      end
      # infos.push(follower_info)
      # infos.push(unblock_info)
      # infos.push(block_info)
    when "oneYear"
      follows = Follow.where("extract(day from date) = ?",1).where(channel_id: channel_id).order("date")
      follows.each do |follow|
        date = follow.date
        title = date.month.to_s+"月"
        follower_info[:data][title] = follow.follower
        unblock_info[:data][title] = follow.targetedReaches
        block_info[:data][title] = follow.blocks
      end
      # infos.push(follower_info)
      # infos.push(unblock_info)
      # infos.push(block_info)
    end
    infos.push(follower_info)
    infos.push(unblock_info)
    infos.push(block_info)
    render json: infos, status: :ok
  end

  def fetch_follows_time_data
    data = fetch_data(params[:timeOption])
    render json: data, status: :ok
  end

  def fetch_data(para)
    @key = para
    infos = []
    channel_id = current_user.target_channel
    follower_info = {
      name: "全友だち数",
      data: {}
    }
    unblock_info = {
      name: "有効友だち数",
      data: {}
    }
    block_info = {
      name: "ブロック数",
      data: {}
    }
    follows = Follow.where(channel_id: channel_id).order("date")
    follow_array = follows.to_a
    case @key
    when "wdaily"
      times = ['日','月','火','水','木','金','土']
      follower_times = [0,0,0,0,0,0,0]
      unblock_times = [0,0,0,0,0,0,0]
      block_times = [0,0,0,0,0,0,0]
      for i in 0...(follow_array.length-1) do
        time = follow_array[i].date.wday
        follow_gap = follow_array[i+1].follower - follow_array[i].follower
        unblock_gap = follow_array[i+1].targetedReaches - follow_array[i].targetedReaches
        block_gap = follow_array[i+1].blocks - follow_array[i].blocks
        follower_times[time] = follower_times[time] + follow_gap
        unblock_times[time] = unblock_times[time] + unblock_gap
        block_times[time] = block_times[time] + block_gap
      end
    when "daily"
      times = ['1日','2日','3日','4日','5日','6日','7日','8日','9日','10日','11日','12日','13日','14日','15日','16日','17日','18日','19日','20日','21日','22日','23日','24日','25日','26日','27日','28日','29日','30日','31日']
      follower_times = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      unblock_times = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      block_times = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      for i in 0...(follow_array.length-1) do
        time = follow_array[i].date.day - 1
        follow_gap = follow_array[i+1].follower - follow_array[i].follower
        unblock_gap = follow_array[i+1].targetedReaches - follow_array[i].targetedReaches
        block_gap = follow_array[i+1].blocks - follow_array[i].blocks
        follower_times[time] = follower_times[time] + follow_gap
        unblock_times[time] = unblock_times[time] + unblock_gap
        block_times[time] = block_times[time] + block_gap
      end
    when "monthly"
      times = ['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月']
      follower_times = [0,0,0,0,0,0,0,0,0,0,0,0]
      unblock_times = [0,0,0,0,0,0,0,0,0,0,0,0]
      block_times = [0,0,0,0,0,0,0,0,0,0,0,0]
      end_month = []
      for i in 0...(follow_array.length-1) do
        follow = follow_array[i]
        if follow.date == follow.date.end_of_month.beginning_of_day
          end_month.push(follow)
        end
      end
      time = follow_array[0].date.month - 1
      follow_gap = end_month[0].follower - follow_array[0].follower
      unblock_gap = end_month[0].targetedReaches - follow_array[0].targetedReaches
      block_gap = end_month[0].blocks - follow_array[0].blocks
      follower_times[time] = follower_times[time] + follow_gap
      unblock_times[time] = unblock_times[time] + unblock_gap
      block_times[time] = block_times[time] + block_gap
      for i in 0...(end_month.length-1) do
        time = end_month[i+1].date.month - 1
        follow_gap = end_month[i+1].follower - end_month[i].follower
        unblock_gap = end_month[i+1].targetedReaches - end_month[i].targetedReaches
        block_gap = end_month[i+1].blocks - end_month[i].blocks
        follower_times[time] = follower_times[time] + follow_gap
        unblock_times[time] = unblock_times[time] + unblock_gap
        block_times[time] = block_times[time] + block_gap
      end
    end
    for i in 0...times.length do
      follower_info[:data][times[i]] = follower_times[i]
      unblock_info[:data][times[i]] = unblock_times[i]
      block_info[:data][times[i]] = block_times[i]
    end
    infos.push(follower_info)
    infos.push(unblock_info)
    infos.push(block_info)
    return infos
  end

  private

  def follows_params
    params.require(:follow).permit(
      :id, :channel_name, :follower, :targetedReaches, :block, :created_at, :updated_at, :date, :channel_id
      )
  end
end