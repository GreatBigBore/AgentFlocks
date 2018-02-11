//
// Created by Rob Bishop on 2/11/18
//
// Copyright © 2018 Rob Bishop
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

class AFMotivatorEditor: AFEditor {
    var count: Int { get { return core.bigData.data[pathToHere].count } }
    
    // Set motivator weight from here, with a big ugly function rather than a nice
    // variable, as a reminder of the underlying GK architecture. I am the container
    // setting a weight for one of my component motivators. The motivator weight is
    // not known by the motivator itself.
    func setWeight(forMotivator name: String, to: Float) {
        getNodeWriter(pathToHere + [name]).write(this: JSON(to), to: "weight")
    }
    
    // Our underlying json has no arrays in it. I made it all dictionaries, mostly because
    // it makes the json easier to read when debugging. But behaviors and goals, in
    // the GameplayKit architecture, are arrays. So here, a bit of a hack to get them
    // to be somewhat array-like (in particular, to remember the order in which elements
    // are added to them). There's some corresponding hackery in the motivators reader,
    // to assign these serial numbers to motivators as they're created. If I ever get to
    // the point where I feel like saving and loading files again, I'll have to read the
    // highest serial number in the incoming data and start the new serial numbers from there.
    subscript(_ ix: Int) -> String {
        let motivators = core.bigData.data[pathToHere].sorted(by: {
            $0.1["serialNumber"].intValue < $1.1["serialNumber"].intValue
        })
        
        return motivators[ix].0  // .0 is the name of the motivator node
    }
}
