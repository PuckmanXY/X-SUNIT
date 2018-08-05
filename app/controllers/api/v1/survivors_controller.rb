module Api
    module V1
        class SurvivorsController < ApplicationController
            
            ## Gets all survivors and calculates abducted and non-abducted percentages
            def index
                survivors = Survivor.order('name ASC')
                abductedPercentage = get_abducted_percentage(survivors)
                ## If there are no survivors, it just makes sense 0% of them is abducted and 0% of then is non-abducted
                if survivors.count == 0
                    nonAbductedPercentage = 0
                else
                    nonAbductedPercentage = 100 - abductedPercentage
                end
                render json: {
                    status: 'SUCCESS',
                    data: survivors,
                    abductedPercentage: abductedPercentage,
                    nonAbductedPercentage: nonAbductedPercentage
                }, status: :ok
            end

            ## Get only the survivor wich id was passed via url param
            def show
                survivor = Survivor.find(params[:id])
                render json: {
                    status: 'SUCCESS',
                    data: survivor
                }, status: :ok
            end

            ## Creates a new survivor
            def create
                survivor = Survivor.new(survivor_params)
                if survivor.save
                    survivor.create_location(
                        latitude: params[:latitude],
                        longitude: params[:longitude]
                    )
                    render json: {
                        status: 'SUCCESS',
                        data: survivor
                    }, status: :ok
                else
                    render json: {
                        status: 'ERROR',
                        message: "couldn't save survivor to database"
                    }, status: :ok
                end
            end

            ## Deletes a survivor
            def destroy
                survivor = Survivor.find(params[:id])
                if survivor.destroy
                    render json: {
                        status: 'SUCCESS',
                        message: 'survivor deleted'
                    }, status: :ok
                else
                    render json: {
                        status: 'ERROR',
                        message: "couldn't delete survivor"
                    }
                end
            end

            def update
                survivor = Survivor.find(params[:id])
                if survivor.update(survivor_params)
                    render json: {
                        status: 'SUCCESS',
                        data: survivor
                    }, status: :ok
                else
                    render json: {
                        status: 'ERROR',
                        message: "couldn't update survivor information"
                    }, status: :unprocessable_entry
                end
            end


            ## Some validations to http methods
            private
            def survivor_params
                params.permit(:name, :age, :gender)
            end

            ## Side-function so it gets easier to change some logic
            def get_abducted_percentage(survivorsArray)
                size = survivorsArray.count
                if size == 0
                    return 0
                else
                    abductedCount = survivorsArray.count{ |survivor| survivor[:abducted] }
                    abductedPercentage = (100 * abductedCount) / size
                    return abductedPercentage
                end
            end

        end
    end
end