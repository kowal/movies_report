# coding: utf-8

require 'spec_helper'

describe FilmDb::BackgroundJob do

  it 'saves jobs under incremented job-id numbers' do
    @job = FilmDb::BackgroundJob.new(%w{ 001 002 009 })
    job_id = @job.save

    expect(job_id).not_to be_nil
    expect { job_id = @job.save }.to change { job_id }
  end

  it 'find job by id' do
    initial_data = %w{ 10 20 30 }
    @job = FilmDb::BackgroundJob.new(initial_data)
    job_id = @job.save

    job = FilmDb::BackgroundJob.find(job_id)

    expect(job).to match_array(initial_data)
  end

end
