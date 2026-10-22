package mapreduce;

import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;

public class RentalMapper extends Mapper<LongWritable, Text, Text, Text> {

    private final Text outputKey = new Text();
    private final Text outputValue = new Text();

    @Override
    protected void map(LongWritable key, Text value, Context context)
            throws IOException, InterruptedException {

        String line = value.toString();

        if (line.startsWith("rental_id")) {
            return;
        }

        String[] fields = line.split(",", -1);
        if (fields.length < 7) {
            return;
        }

        String carId = fields[1].trim();
        String rentalStart = fields[3].trim();
        String status = fields[6].trim();

        if (rentalStart.length() < 4) {
            return;
        }

        String rentalYear = rentalStart.substring(0, 4);
        int completedFlag = "Completed".equalsIgnoreCase(status) ? 1 : 0;

        outputKey.set(carId + "," + rentalYear);
        outputValue.set("1," + completedFlag);

        context.write(outputKey, outputValue);
    }
}
