require_relative '../helpers/spec_helper'

describe Krakow do

  before do
    @nsqd = Krakow::Nsqd.new
    @nsqd.run!
  end

  after do
    @nsqd.halt!
  end

  describe Krakow::Consumer do

    describe 'Direct connection' do

      before do
        @topic = TOPIC_NAME.shuffle.join
        host, port = @nsqd.nsqd_tcp_addresses.first.split(':')
        @producer = Krakow::Producer.new(
          :host => host,
          :port => port,
          :topic => @topic
        )
        @consumer = Krakow::Consumer.new(
          :host => host,
          :port => port,
          :topic => @topic,
          :channel => '_default'
        )
        wait_for{ @producer.connected? && !@consumer.connections.empty? }
      end

      after do
        sleep(0.2) # cooldown
        @producer.terminate
        @consumer.terminate
      end

      it 'should have a queue with a size' do
        @consumer.queue.size.must_equal 0
      end

      it 'should wait for messages' do
        ->{ wait_for(0.2){ @consumer.queue.pop } }.must_raise Timeout::Error
      end

      it 'should receive messages' do
        @producer.write('krakow-test').response.must_equal 'OK'
        @consumer.queue.pop.message.must_equal 'krakow-test'
      end

      it 'should receive stream of messages' do
        msgs = 100.times.map{ TOPIC_NAME.shuffle.join }
        @producer.write(*msgs).response.must_equal 'OK'
        msgs.each do |msg|
          result = @consumer.queue.pop
          result.message.must_equal msg
          result.confirm
        end
      end

    end

    describe 'Discovery connection' do

      before do
        @topic = TOPIC_NAME.shuffle.join
        host, port = @nsqd.nsqd_tcp_addresses.first.split(':')
        @producer = Krakow::Producer.new(
          :host => host,
          :port => port,
          :topic => @topic
        )
        wait_for{ @producer.connected? }
        @producer.write('seed')
        sleep(1)
        @consumer = Krakow::Consumer.new(
          :nsqlookupd => @nsqd.lookupd_http_addresses.first,
          :topic => @topic,
          :channel => '_default'
        )
        wait_for{ @consumer.connections.values.all?{|c| c.connected?} }
      end

      after do
        sleep(0.2) # cooldown
        @producer.terminate
        @consumer.terminate
      end

      it 'should have an nsqd connection' do
        @consumer.connections.wont_be :empty?
        @consumer.connections.values.first.connected?.must_equal true
      end

      it 'should receive messages' do
        msg = @consumer.queue.pop
        msg.message.must_equal 'seed'
        @consumer.confirm(msg)
        @producer.write('krakow-test').response.must_equal 'OK'
        @consumer.queue.pop.message.must_equal 'krakow-test'
      end

    end
  end

end
