package mapreduce;

import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;
import java.util.Locale;

public class RentalReducer extends Reducer<Text, Text, Text, Text> {

    private final Text outputValue = new Text();

    @Override
    protected void reduce(Text key, Iterable<Text> values, Context context)
            throws IOException, InterruptedException {

        int totalRentals = 0;
        int completedRentals = 0;

        for (Text val : values) {
            String[] parts = val.toString().split(",");
            int count = Integer.parseInt(parts[0]);
            int completed = Integer.parseInt(parts[1]);

            totalRentals += count;
            completedRentals += completed;
        }

        double completedRatio = (totalRentals > 0)
                ? (double) completedRentals / totalRentals
                : 0.0;

        outputValue.set(totalRentals + "," + String.format(Locale.US, "%.4f", completedRatio));
        context.write(key, outputValue);
    }
}
