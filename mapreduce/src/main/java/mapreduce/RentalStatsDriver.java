package mapreduce;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class RentalStatsDriver extends Configured implements Tool {

    @Override
    public int run(String[] args) throws Exception {

        String inputPath = "input/datasource1";
        String outputPath = "output/mapreduce_result";

        if (args.length >= 2) {
            inputPath = args[args.length - 2];
            outputPath = args[args.length - 1];
        }

        Configuration conf = getConf();
        conf.set("mapreduce.output.textoutputformat.separator", ",");

        Job job = Job.getInstance(conf, "Rental Statistics");
        job.setJarByClass(RentalStatsDriver.class);

        job.setMapperClass(RentalMapper.class);
        job.setCombinerClass(RentalCombiner.class);
        job.setReducerClass(RentalReducer.class);

        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(Text.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);

        job.setInputFormatClass(TextInputFormat.class);
        job.setOutputFormatClass(TextOutputFormat.class);

        FileInputFormat.addInputPath(job, new Path(inputPath));
        FileOutputFormat.setOutputPath(job, new Path(outputPath));

        return job.waitForCompletion(true) ? 0 : 1;
    }

    public static void main(String[] args) throws Exception {
        int exitCode = ToolRunner.run(new Configuration(), new RentalStatsDriver(), args);
        System.exit(exitCode);
    }
}
