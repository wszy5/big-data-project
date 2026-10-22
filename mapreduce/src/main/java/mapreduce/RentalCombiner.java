package mapreduce;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;

public class RentalCombiner extends Reducer<Text, Text, Text, Text> {

    private final Text outputValue = new Text();

    @Override
    protected void reduce(Text key, Iterable<Text> values, Context context)
            throws IOException, InterruptedException {

        int totalRentals = 0;
        int completedRentals = 0;

        for (Text val : values) {
            String[] parts = val.toString().split(",");
            totalRentals += Integer.parseInt(parts[0]);
            completedRentals += Integer.parseInt(parts[1]);
        }

        outputValue.set(totalRentals + "," + completedRentals);
        context.write(key, outputValue);
    }
}
