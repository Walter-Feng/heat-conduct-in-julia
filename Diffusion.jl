function Diffusion!(array,width::Int64,boxwidth,Df,t)

	changelist = fill(0.0,width)

	changelist[1] = - Df*t*( array[1] - array[2] )/boxwidth

	for iterator in 2:width-1
		changelist[iterator] = Df * t * (array[iterator-1] - array[iterator]) / boxwidth - Df * t * (array[iterator] - array[iterator+1]) / boxwidth
	end

	changelist[width] = Df*t* ( array[width-1] - array[width] )/(boxwidth)/boxwidth

	for iterator in 1:width
		array[iterator] = array[iterator] + changelist[iterator]
	end

end


function mixing!(array,pos)
	temp = array[pos]
	array[pos] = array[pos+1]
	array[pos + 1] = temp
end


function diffusionin1d(heatspeed::Float64,cuttemp::Float64,width::Int64,boxwidth::Float64,Df::Float64,t::Float64,iteration::Int64,outputfilename; heatpos = [1], mixpos = 0, mixcountmax = 1, roomtemp::Float64 = 25.0 , tempdetectpos = 3, recordpos = [3])
	
	open(outputfilename,"w") do f

		write(f,"Initial condition:\n",
				"The speed of heating: $heatspeed \n",
				"Cut of temperature: $cuttemp \n",
				"width of the system: $width \n",
				"width of the box: $boxwidth \n",
				"Diffusion coefficient: $Df \n",
				"Δt: $t \n",
				"total iteration: $iteration \n",
				"mixing position: $mixpos \n",
				"max counter of mixing: $mixcountmax \n",
				"room temperature: $roomtemp \n",
				"The position of detecting temp: $tempdetectpos \n")

		array = fill(roomtemp,width)

		mixcount = 1

		for i in 1:iteration
			elapsedtime = i * t

			if(array[tempdetectpos] <= cuttemp)
				for h in heatpos
					array[h] = array[h] + heatspeed * t
				end
			end

			Diffusion!(array,width,boxwidth,Df,t)

			array[width] = roomtemp

				write(f,"t = $elapsedtime  : \n")

				for k in recordpos
					write(f,"$(array[k])    ")
				end

				write(f,"\n")

			if(mixpos != 0)
				if(mixcount >= mixcountmax)
					mixing!(array,mixpos)
					mixcount = 0
				end
				mixcount = mixcount + 1
			end

		end
	end
end

function executor(filename)
	open(filename) do f
		tempstring = readline(f)
		while tempstring != ""
			eval(Meta.parse(tempstring))
			tempstring = readline(f)
		end
	end
end

function indextable(q)
	temp = fill(0,q)
	for i in 1:q
		temp[i] = i
	end
end


