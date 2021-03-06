require_relative 'auxiliary_functions'

module Api
    module V1
        class AbductionReportsController < ApplicationController
            
            ## Create a new abduction report
            def create
                ## Having a reference to survivor and witness objects, we make sure they exist
                survivor = Survivor.find(params[:survivor_id])
                witness = Survivor.find(params[:witness_id])
                validation = validate_report(survivor, witness)
                if validation[:status]
                    abductionReport = AbductionReport.new(abduction_report_params)
                    abductionReport.save
                    witnessesReportingAbduction = find_witnesses(survivor.id)
                    if witnessesReportingAbduction >= 3 and survivor[:abducted] == false
                        survivor.update(abducted: true)
                    end
                    status = 'SUCCES'
                    data = {
                        message: validation[:message],
                        abduction_report: abductionReport
                    }
                    statusCode = 200
                else
                    status = 'ERROR'
                    data = {
                        message: validation[:message]
                    }
                    statusCode = 400
                end
                render_response(status, data, statusCode)
            end

            private
            def abduction_report_params
                params.permit(:survivor_id, :witness_id)
            end

            ## Side-function to count how many witnesses reported survivor abductions
            private
            def find_witnesses(survivor_id)
                survivorAbductionReports = AbductionReport.find_by(survivor_id: survivor_id)
                witnessesReportingAbduction = survivorAbductionReports.map { |report| report[:witness_id] }.uniq.count
                return witnessesReportingAbduction
            end

            ## Side-function so the code gets clean
            private
            def validate_report(survivor, witness)
                status = false
                ## A survivor shouldn't be able to report his own abduction since he's probably in the UFO
                if survivor.id == witness.id
                    message = "a survivor can't report his own abduction"
                ## If a survivor already reported antoher survivor abduction, then the array below should be empty
                elsif AbductionReport.find_by(witness_id: witness.id, survivor_id: survivor.id) != nil
                    message = "witness already reported this abduction"
                ## If an abducted survivor is reporting another survivor abduction, then we have a problem
                elsif witness.abducted
                    message = "an abducted survivor can't report another survivor abduction"
                else
                    status = true
                    message = "abduction reported"
                end
                return { status: status, message: message }
            end
        end
    end
end
